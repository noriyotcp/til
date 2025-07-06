---
allowed-tools: Glob(**/*.md), Read, LS, Bash(find:*), Bash(grep:*), Bash(wc:*)
description: Comprehensive documentation analysis and consistency checker
---

# Documentation Update & Consistency Checker

**Universal documentation analysis and consistency check command**

This command automatically discovers documentation within a project, checks for consistency and coherence, and provides update recommendations.

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

**Execution Commands**:
```bash
# Primary document discovery
!`find . -maxdepth 1 -name "*.md" -type f | grep -E "(README|CLAUDE|CHANGELOG)" || echo "Primary documents not found"`

# All Markdown file discovery
!`find . -name "*.md" -type f | head -20`

# Documentation directory discovery
!`find . -type d -name "*doc*" -o -name "docs" -o -name "ai-docs" -o -name "documentation" 2>/dev/null || echo "No documentation directories"`
```

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

**Execution Commands**:
```bash
# Detailed analysis of primary documents
Read @README.md @CLAUDE.md content and analyze the following:

# Metadata consistency check
!`grep -i "version\|版本\|バージョン" *.md 2>/dev/null || echo "No version information found"`
!`grep -i "status\|ステータス\|状態" *.md 2>/dev/null | head -5`

# Project name consistency
!`grep -o "^# .*" *.md 2>/dev/null | head -3`

# Heading structure verification
!`grep "^##" *.md 2>/dev/null | head -10`

# Duplicate content detection (search for similar headings)
!`grep "^##" *.md 2>/dev/null | sort | uniq -c | sort -nr | head -5`
```

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

**Execution Commands**:
```bash
# Project configuration file verification
!`find . -maxdepth 2 -name "package.json" -o -name "*.gemspec" -o -name "Cargo.toml" -o -name "pyproject.toml" 2>/dev/null || echo "Configuration files not found"`

# CLI command implementation status check (for Ruby projects)
!`find . -name "*cli*" -o -name "*command*" | grep -v ".md" | head -5 || echo "CLI implementation files not found"`

# Test file count verification
!`find . -name "*spec*" -o -name "*test*" | grep -E "\\.(rb|js|py|ts)$" | wc -l || echo "0"`

# Source code line count estimation
!`find . -name "*.rb" -o -name "*.js" -o -name "*.py" -o -name "*.ts" | grep -v node_modules | grep -v vendor | xargs wc -l 2>/dev/null | tail -1 || echo "Line count unknown"`

# Git repository status
!`git status --porcelain 2>/dev/null | wc -l || echo "Not a Git repository"`
!`git log --oneline -5 2>/dev/null || echo "No Git history"`
```

1. **Codebase Analysis**
   - Discrepancies between implementation status and documentation
   - Feature list accuracy
   - Current state reflection of API/CLI commands

2. **Configuration File Verification**
   - Information extraction from package.json, gemspec, etc.
   - Latest dependency status
   - Version information synchronization

3. **Quality Metrics**
   - Test file count verification
   - Code line count and reduction rate validation
   - Quality indicator updates

### Phase 4: Update Recommendations & Prioritization
Generate specific update recommendations from analysis results:

**Analysis Instructions**:
Based on the automatic check results above, execute comprehensive analysis from the following perspectives:

**Important**: When generating the final report, only include sections that were actually analyzed based on $ARGUMENTS. If a specific focus was requested, tailor the report accordingly.

1. **Discrepancy Reports**
   - Details of discovered inconsistencies
   - Impact and importance evaluation
   - Identification of correction points

2. **Correction Proposals**
   - Specific update content suggestions
   - Description methods that should be unified
   - Recommendations for information to be added

3. **Prioritization & Action Plans**
   - Correction order based on urgency
   - Recommended update timing
   - Future maintenance proposals

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

This command enables continuous maintenance and improvement of project documentation quality.
