# Sagebrush Standard Creator

Create professional legal standards with structured metadata through an iterative writer-reviewer dialogue process.

## What This Skill Does

This skill creates Sagebrush Standards by orchestrating a dialogue between two specialized agents:

1. **Legal Writer Agent**: Drafts the standard with professional legal analysis
2. **Law School Professor Agent**: Reviews and grades the standard until it achieves A-grade quality

The skill manages the iterative process: draft → review → revise → review → ... → approved.

## When to Use This Skill

Use this skill when you need to create a new Sagebrush Standard, which is a professional legal document with:
- YAML front matter defining Flow (end-user questions) and Alignment (staff tasks)
- Professional legal content written from a lawyer's perspective
- A-grade quality as evaluated by law school professor standards

Reference: https://www.sagebrush.services/standards/spec

## What is a Sagebrush Standard?

A Sagebrush Standard is a Markdown document with structured YAML front matter that guides both clients and law firm
staff through legal processes. Examples include:
- Trust formation (Nevada Trust, California Trust)
- Entity formation (Delaware Corporation, Nevada LLC)
- Estate planning documents (Wills, Powers of Attorney)
- Employment agreements
- Regulatory compliance workflows

## The Creation Process

This skill follows a rigorous iterative process:

### Phase 1: Initial Draft

1. **Gather requirements** from the user:
   - What legal domain? (trusts, corporations, employment, etc.)
   - What jurisdiction? (Nevada, Delaware, California, etc.)
   - What is the purpose of this standard?
   - Who is the respondent? (person or organization)

2. **Launch legal-writer agent** with the Task tool:
   - Provide clear requirements
   - Request complete standard with YAML front matter and professional legal content
   - Specify the target file location

### Phase 2: Professor Review

3. **Launch law-school-professor agent** with the Task tool:
   - Request rigorous review of the drafted standard
   - Request grading using law school criteria
   - Request specific, actionable feedback

4. **Evaluate the grade**:
   - If **A-grade (90-100)**: Standard is complete! Run final validation.
   - If **< A-grade**: Proceed to revision phase.

### Phase 3: Iterative Revision (if needed)

5. **Launch legal-writer agent** again with professor's feedback:
   - Provide specific issues identified by professor
   - Request revisions to address all feedback
   - Emphasize that A-grade quality is required

6. **Launch law-school-professor agent** again:
   - Review the revised standard
   - Provide updated grading and feedback

7. **Repeat steps 5-6** until A-grade achieved (maximum 5 iterations)

### Phase 4: Final Validation

8. **Run standards lint** to ensure technical compliance:
   ```bash
   cd [directory-containing-standard]
   standards lint .
   ```

9. **If lint violations found**:
   - Run `standards lint . --fix` to auto-correct
   - If auto-fix fails, launch legal-writer to manually correct

10. **Present final standard** to user with summary:
    - Location of the file
    - Grade achieved
    - Key features of the standard
    - Flow summary (end-user journey)
    - Alignment summary (staff workflow)

## Required Agents

This skill depends on two agents that must exist in `.claude/agents/`:

- **legal-writer**: Expert legal writer who drafts standards
- **law-school-professor**: Rigorous reviewer who grades standards

These agents will be automatically available after running `standards setup`.

## Usage Examples

### Example 1: Simple Trust

**User Request**: "Create a standard for a Nevada revocable living trust"

**Your Process**:
1. Gather details: respondent_type is "person", jurisdiction is Nevada
2. Launch legal-writer agent to draft initial standard
3. Launch professor agent to review
4. If revisions needed, iterate between writer and professor
5. Run `standards lint .` for final validation
6. Present completed standard

### Example 2: Corporation with Options

**User Request**: "Create a Delaware corporation formation standard with support for multiple share classes"

**Your Process**:
1. Gather details: respondent_type is "org", jurisdiction is Delaware, feature is multi-class stock
2. Launch legal-writer agent with specification about branching flow for single vs. multi-class
3. Launch professor agent to review
4. Iterate as needed
5. Run `standards lint .`
6. Present completed standard

## Agent Communication Protocol

### Launching Legal-Writer (Initial Draft)

```
Create a new Sagebrush Standard with the following specifications:

**Domain**: [Trust Formation / Corporation Formation / etc.]
**Jurisdiction**: [Nevada / Delaware / California / etc.]
**Respondent Type**: [person / org]
**Code**: [suggested_snake_case_identifier]
**Purpose**: [Brief description of what this standard accomplishes]

**Special Requirements**:
- [Any branching logic needed in Flow]
- [Any special staff workflows in Alignment]
- [Any jurisdiction-specific considerations]

Create the standard at: [file path]

Ensure:
1. Complete YAML front matter with logical Flow and Alignment state machines
2. Professional legal analysis with proper citations
3. No pronouns - all parties referenced by role
4. Active voice throughout
5. All lines ≤ 120 characters
6. A-grade quality legal writing

Research applicable law and draft a comprehensive standard.
```

### Launching Professor (Review)

```
Review the Sagebrush Standard at: [file path]

Grade this standard using rigorous law school criteria across four dimensions:
1. Legal Analysis (40%)
2. Writing Quality (30%)
3. Citations & Research (15%)
4. Technical Structure (15%)

Provide:
- Overall grade (A/B/C/D/F) with numeric score
- Specific feedback on each dimension
- Line-by-line issues with specific corrections needed
- Required actions for the legal-writer to achieve A-grade

Remember: Only A-grade work (90-100) is acceptable for publication.

Also verify technical compliance by running: standards lint [directory]
```

### Launching Legal-Writer (Revision)

```
Revise the Sagebrush Standard at: [file path]

The law school professor has reviewed your standard and identified the following issues:

[Paste professor's feedback here]

Current Grade: [score]/100
Required Grade: 90+/100 (A)

Please revise the standard to address ALL issues identified by the professor. Specifically:

[List specific action items from professor's feedback]

After revision, ensure:
- All professor feedback addressed
- All lines still ≤ 120 characters
- No new issues introduced
- A-grade quality achieved
```

## Standards CLI Integration

This skill leverages the `standards` CLI for validation:

### Lint Command

After the writer-professor dialogue completes, always run:

```bash
cd [directory-containing-standard]
standards lint .
```

This validates:
- All lines ≤ 120 characters
- No trailing whitespace
- Valid Markdown structure

If violations found:
```bash
standards lint . --fix
```

The CLI will automatically fix line length issues by intelligently reflowing text.

### Expected File Location

Standards should be created in:
- **During development**: `/Users/nick/Code/NLF/Standards/Sources/StandardsDAL/Examples/[Category]/[jurisdiction].md`
- **After setup**: `~/Standards/[ProjectName]/[jurisdiction]_[type].md`

Categories include: `Trusts`, `Corporations`, `LLCs`, `Employment`, `Wills`, etc.

## Success Criteria

A standard is complete when:

✅ Professor assigns A-grade (90-100)
✅ `standards lint .` passes with no violations
✅ YAML front matter is complete
✅ Flow state machine begins at BEGIN and ends at END
✅ Alignment state machine begins at BEGIN and ends at END
✅ No pronouns in content
✅ Active voice throughout
✅ Proper legal citations
✅ Professional tone and structure

## Error Handling

### If Writer Struggles (After 2 Iterations)

Provide more specific guidance:
- Identify the weakest dimension (legal analysis, writing, citations, technical)
- Give example text showing desired quality
- Reference existing A-grade standards as models

### If Professor is Too Harsh (Unrealistic Grade)

Review professor feedback:
- Is feedback justified by actual issues?
- Are requested changes achievable?
- If professor feedback seems off, ask user for guidance

### If Lint Violations Persist

After `standards lint . --fix`:
- If still failing, launch legal-writer specifically to fix line length
- Provide exact line numbers needing manual attention
- Do not proceed until lint passes

### Maximum Iterations Exceeded

If 5 iterations occur without A-grade:
- Summarize the recurring issues
- Ask user if standards should be lowered or different approach taken
- Consider if requirements were unclear

## Workflow Diagram

```
User Request
    ↓
Gather Requirements
    ↓
Launch legal-writer (draft)
    ↓
Launch professor (review)
    ↓
Grade < 90? ─no→ Run standards lint
    │                      ↓
    yes              Violations? ─no→ DONE ✓
    │                      │
    ↓                     yes
Launch legal-writer       ↓
   (revise)         Run lint --fix
    │                      ↓
    ↓              Violations? ─no→ DONE ✓
Launch professor           │
   (review)               yes
    │                      ↓
    └─→ (iterate)    Manual fixes needed
```

## Quality Philosophy

This skill embodies the principle that **professional legal work deserves professional quality standards**. By having
a law school professor review every standard, we ensure:

- Accurate legal analysis
- Clear, precise writing
- Proper research and citation
- Technical excellence
- Professional presentation

The iterative dialogue between writer and professor mirrors the real-world process of legal writing, where drafts are
reviewed, revised, and refined until they meet publication standards.

## Tips for Best Results

1. **Be specific in requirements**: The more detail you provide, the better the initial draft
2. **Trust the process**: Multiple iterations are normal and expected
3. **Don't skip validation**: Always run `standards lint .` at the end
4. **Review the final standard**: Read through it yourself to ensure it meets your needs
5. **Provide examples**: If you have similar standards, share them with the legal-writer

## Integration with Standards CLI

After creating standards with this skill, use the Standards CLI to:

- **Lint standards**: `standards lint .`
- **Sync to Sagebrush API**: `standards sync push [project]`
- **Package standards**: `standards zip [project]`
- **Setup development environment**: `standards setup`

## Final Notes

This skill produces publication-ready legal standards through rigorous peer review. The dialogue between legal-writer
and law-school-professor ensures every standard meets the highest professional standards before release.

Remember: Legal work impacts people's lives, businesses, and futures. We don't publish anything less than A-grade.
