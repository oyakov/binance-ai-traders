# MEM-F001: Java Version Documentation Inconsistency

## Status
**Active** | **Severity**: Medium | **Impact**: Documentation Accuracy

## Last Updated
2025-10-18

## Summary
Inconsistent Java version references across project documentation. Root README.md states Java 17, but pom.xml and AGENTS.md correctly specify Java 21.

## Details

### Inconsistent References
- **README.md**: Lines 51, 78, 156 reference "Java 17"
- **binance-ai-traders/services/binance-data-storage.md**: Line 3 says "Java 17"
- **binance-ai-traders/services/binance-trader-macd.md**: Line 3 says "Java 17"

### Correct References
- **pom.xml**: Lines 24-25 specify Java 21 (maven.compiler.source/target)
- **binance-ai-traders/AGENTS.md**: Line 17-21 correctly states "Java 21, Spring Boot 3.3.9"

## Root Cause
Documentation not updated when project was upgraded from Java 17 to Java 21.

## Impact
- New developers may install wrong Java version
- Confusion about project requirements
- Potential build failures if Java 17 used

## Recommendation
1. Update README.md to specify Java 21
2. Update all service documentation files to Java 21
3. Verify all documentation references consistently use Java 21
4. Add version checking in build scripts

## Related Entries
- **MEM-C004**: Microservices Detailed Analysis (references Java 21)
- **MEM-C001**: Project Architecture Overview (needs update)

## Remediation Status
- [ ] README.md updated
- [ ] binance-ai-traders/README.md updated
- [ ] Service documentation updated
- [ ] Cross-reference validation complete

---

**Created**: 2025-10-18  
**Type**: Finding  
**Scope**: global-documentation


