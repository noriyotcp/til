---
allowed-tools: Glob(**/*.md), Read, LS, Bash(find:*), Bash(grep:*), Bash(wc:*), Edit, MultiEdit
description: Comprehensive documentation analysis and automated consistency maintenance
---

# Documentation Update & Consistency Checker

**Universal documentation analysis and automated consistency maintenance command**

This command automatically discovers documentation within a project, checks for consistency and coherence, and applies fixes to maintain documentation quality.

**Important**: The command examples throughout this document are illustrative patterns. Adapt them to match your project's:
- Programming language(s) and file extensions
- Documentation structure and naming conventions
- Build tools and configuration files
- Testing frameworks and patterns

## Argument Handling

When arguments are provided via $ARGUMENTS, they are parsed to determine focus areas:
- If $ARGUMENTS contains "metadata": Focus on metadata consistency analysis
- If $ARGUMENTS contains "structure": Focus on document structure and formatting
- If $ARGUMENTS contains "content": Focus on content duplication and conflicts
- If $ARGUMENTS is empty: Perform full comprehensive analysis

**Note**: Parse $ARGUMENTS as a simple string. Check for keywords to determine the analysis scope.

## Execution Steps

### Phase 1: Document Auto-Discovery
Execute universal document discovery that doesn't depend on project structure:
*Note: This phase always executes regardless of focus area, as it's needed for all analysis types.*

**Example Commands** (adapt these patterns to your project):
```bash
# Primary document discovery
!`find . -maxdepth 1 -name "*.md" -type f | grep -E "(README|CLAUDE|CHANGELOG)" || echo "Primary documents not found"`

# All Markdown file discovery
!`find . -name "*.md" -type f | head -20`

# Documentation directory discovery
!`find . -type d -name "*doc*" -o -name "docs" -o -name "ai-docs" -o -name "documentation" 2>/dev/null || echo "No documentation directories"`
```

**Note**: The above commands are examples. Adjust file patterns and directory names based on your project's documentation structure.

1. **Primary Document Detection**
   - Verify existence of README.md, CLAUDE.md
   - List *.md files in project root

2. **Documentation Directory Discovery**
   - Search for docs/, doc/, ai-docs/, documentation/
   - Dynamically discover other documentation-related directories

3. **Priority Classification**
   - Primary: README, CLAUDE, CHANGELOG files
   - Secondary: Technical documentation, FEATURES, ARCHITECTURE
   - Planning: ROADMAP, TODO, PLAN files

### Phase 2: Content Analysis & Consistency Check
Analyze the content of discovered documents and check the following:
*Execute based on focus area - skip sections if specific focus is requested via $ARGUMENTS.*

**Example Commands** (adapt search patterns to your project's language and conventions):
```bash
# Detailed analysis of primary documents
Read @README.md @CLAUDE.md content and analyze the following:

# Metadata consistency check (example includes multiple languages)
!`grep -i "version\|版本\|バージョン" *.md 2>/dev/null || echo "No version information found"`
!`grep -i "status\|ステータス\|状態\|état\|estado" *.md 2>/dev/null | head -5`

# Project name consistency
!`grep -o "^# .*" *.md 2>/dev/null | head -3`

# Heading structure verification
!`grep "^##" *.md 2>/dev/null | head -10`

# Duplicate content detection (search for similar headings)
!`grep "^##" *.md 2>/dev/null | sort | uniq -c | sort -nr | head -5`
```

**Note**: Customize grep patterns based on your project's metadata keywords and language.

1. **Metadata Consistency** *(Execute if: $ARGUMENTS is empty or contains "metadata")*
   - Version information unification
   - Date and status information coherence
   - Project name and description alignment

2. **Structural Consistency** *(Execute if: $ARGUMENTS is empty or contains "structure")*
   - Heading structure standardization
   - Section order unification
   - Format notation consistency

3. **Content Duplication & Conflicts** *(Execute if: $ARGUMENTS is empty or contains "content")*
   - Information duplication across multiple files
   - Detection of contradictory descriptions
   - Identification of outdated information

### Phase 3: Project Status Synchronization
Check synchronization between actual project status and documentation:

**Example Commands** (adapt file extensions and patterns to your technology stack):
```bash
# Project configuration file verification (covers multiple ecosystems)
!`find . -maxdepth 2 -name "package.json" -o -name "*.gemspec" -o -name "Cargo.toml" -o -name "pyproject.toml" -o -name "go.mod" -o -name "pom.xml" -o -name "build.gradle" 2>/dev/null || echo "Configuration files not found"`

# CLI/Command implementation status check (language-agnostic)
!`find . -name "*cli*" -o -name "*command*" | grep -v ".md" | head -5 || echo "CLI implementation files not found"`

# Test infrastructure discovery (qualitative assessment)
!`find . -name "*spec*" -o -name "*test*" -type d | head -3 || echo "No test directories found"`

# Source code discovery (architecture assessment, not counting)
!`find . -name "*.rb" -o -name "*.js" -o -name "*.py" -o -name "*.ts" -o -name "*.go" -o -name "*.java" | grep -v node_modules | grep -v vendor | head -5 || echo "Source files discovery"`

# Git repository status (qualitative assessment)
!`git status --porcelain 2>/dev/null | head -3 || echo "No uncommitted changes"`
!`git log --oneline -5 2>/dev/null || echo "No Git history"`
```

**Note**: Replace or add file extensions based on your project's programming languages. Common patterns:
- JavaScript/TypeScript: `*.js`, `*.ts`, `*.jsx`, `*.tsx`
- Python: `*.py`
- Ruby: `*.rb`
- Go: `*.go`
- Java/Kotlin: `*.java`, `*.kt`
- Rust: `*.rs`
- C/C++: `*.c`, `*.cpp`, `*.h`, `*.hpp`

1. **Codebase Analysis**
   - Discrepancies between implementation status and documentation
   - Feature list accuracy
   - Current state reflection of API/CLI commands

2. **Configuration File Verification**
   - Information extraction from package.json, gemspec, etc.
   - Latest dependency status
   - Version information synchronization

3. **Quality Metrics**
   - Test infrastructure discovery
   - Architecture assessment and quality verification
   - Quality indicator status updates

### Phase 4: Automatic Analysis & Updates
Analyze findings and automatically apply fixes where appropriate:

**Analysis & Auto-Update Instructions**:
Based on the automatic check results above, execute comprehensive analysis and apply fixes:

**Important**: When generating the final report, only include sections that were actually analyzed based on $ARGUMENTS. If a specific focus was requested, tailor the report accordingly.

1. **Discrepancy Detection & Auto-Fix**
   - Identify inconsistencies in version numbers, status descriptions, command counts
   - Automatically update simple numeric discrepancies
   - Apply consistent formatting and naming conventions

2. **Content Synchronization**
   - Cross-reference information between primary documents
   - Update outdated phase statuses and completion indicators
   - Unify terminology and descriptions across files

3. **Improvement Implementation**
   - Apply structural improvements to heading organization
   - Update cross-references and internal links
   - Enhance consistency in documentation style

**Auto-Update Process**:
- **Safe Updates**: Automatically fix obvious inconsistencies (numbers, formatting, typos)
- **Structural Changes**: Apply non-destructive improvements to organization
- **Content Preservation**: Maintain all original information while improving consistency

**Comprehensive Report Generation**:
Synthesize all automatic check results and create a report in the following format:

```markdown
# 📋 Documentation Analysis Report

## 🔍 Discovered Documents
- **Primary**: [README.md, CLAUDE.md, etc.]
- **Secondary**: [FEATURES.md, ARCHITECTURE.md, etc.]  
- **Planning**: [ROADMAP.md, PLAN files, etc.]

## ⚠️ Consistency Check Results
- 🔴 **Critical Issues**: X items (must fix)
- 🟡 **Minor Issues**: Y items (recommended fix)
- 🟢 **Improvement Suggestions**: Z items (optional improvement)

## 🔧 Correction Proposals (by priority)
### High Priority 🔴
1. [Specific correction items and locations]
2. [High-impact inconsistencies]

### Medium Priority 🟡  
1. [Items to be improved]
2. [Descriptions to be unified]

### Low Priority 🟢
1. [Optional improvement items]
2. [Future expansion plans]

## 📈 Project Status
- **Codebase**: [Synchronization status]
- **Quality Metrics**: [Update status]
- **Recommended Actions**: [Next steps]
```

## Output Format

```markdown
## Documentation Analysis Report

### 📋 Discovered Documents
- Primary: [list]
- Secondary: [list]  
- Planning: [list]

### ⚠️ Consistency Check Results
- Critical issues: [count] items
- Minor issues: [count] items
- Improvement recommendations: [count] items

### 🔧 Correction Proposals (by priority)
1. [High priority correction items]
2. [Medium priority correction items]
3. [Low priority correction items]

### 📈 Project Status
- Codebase synchronization status
- Quality metrics verification
- Items requiring updates
```

## Usage Examples

```bash
# Full comprehensive documentation analysis
/project:update-docs

# Focus on metadata consistency only
/project:update-docs metadata

# Focus on document structure analysis
/project:update-docs structure

# Focus on content duplication detection
/project:update-docs content

# Multiple focus areas (space-separated)
/project:update-docs metadata structure

# All analyses (same as no arguments)
/project:update-docs metadata structure content
```

This command enables continuous maintenance and improvement of project documentation quality through automated analysis and updates.
