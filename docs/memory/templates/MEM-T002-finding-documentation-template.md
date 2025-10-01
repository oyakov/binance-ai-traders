# Finding Documentation Template

**Template ID**: MEM-T002  
**Type**: Template  
**Status**: Active  
**Created**: 2024-12-25  
**Usage**: Findings  

## Template Structure

```markdown
# MEM-XXX: [Finding Title]

**Type**: Finding  
**Status**: [Active/Resolved/Outdated]  
**Created**: [YYYY-MM-DD]  
**Last Updated**: [YYYY-MM-DD]  
**Impact Scope**: [Service/Component/Global]  

## Summary
[Brief one-paragraph summary of the finding]

## Details
[Detailed description of the finding]

### Current State
[What currently exists or is implemented]

### Issues Identified
[Specific problems or gaps identified]

### Root Cause
[Analysis of why the issues exist]

### Impact Assessment
[How the issues affect the system]

## Evidence
[Code references, configuration examples, or other evidence]

## Recommendations
[Specific actionable recommendations]

### Immediate Actions
[What should be done right away]

### Long-term Actions
[What should be done over time]

### Risk Mitigation
[How to reduce risks while implementing fixes]

## Related Documentation
[Links to related documentation and findings]

## Code References
[Specific files, functions, or configurations]

## Next Steps
[Action items with checkboxes]

## Verification
[How to verify the finding is accurate]

## Dependencies
[What other work depends on this finding]
```

## Usage Guidelines

### When to Use
- Documenting significant discoveries
- Recording architectural issues
- Tracking implementation gaps
- Documenting security concerns

### Required Sections
- Summary
- Details
- Recommendations
- Code References
- Next Steps

### Optional Sections
- Evidence (for complex findings)
- Root Cause (for problem analysis)
- Impact Assessment (for critical findings)
- Verification (for findings that need validation)
- Dependencies (for findings that affect other work)

### Status Values
- **Active**: Finding is current and relevant
- **Resolved**: Finding has been addressed
- **Outdated**: Finding is no longer relevant

### Impact Scope Values
- **Service**: Affects a specific service
- **Component**: Affects a specific component
- **Global**: Affects the entire system

### Naming Convention
- Use descriptive titles that clearly identify the finding
- Include the service or component name when applicable
- Use kebab-case for file names

### Maintenance
- Update status when findings are resolved
- Review findings regularly for accuracy
- Archive outdated findings
- Cross-reference related findings
