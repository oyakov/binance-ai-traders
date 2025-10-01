# Service Documentation Template

**Template ID**: MEM-T001  
**Type**: Template  
**Status**: Active  
**Created**: 2024-12-25  
**Usage**: Services  

## Template Structure

```markdown
# [Service Name] Service

**Language**: [Java 17/Python 3.11], [Spring Boot/FastAPI]  
**Status**: [Active/Development/Deprecated]  
**Last Updated**: [YYYY-MM-DD]  

## Purpose
[Brief description of what the service does and its role in the system]

## Current Implementation
[Detailed description of what is currently implemented]

### Configuration
[Configuration options, environment variables, and their descriptions]

### Architecture
[High-level architecture and key components]

### API Endpoints
[If applicable, list of REST endpoints]

### Data Models
[Key data models and their purposes]

## Dependencies
[External and internal dependencies]

## Missing Pieces & Risks
[What's missing and potential risks]

## Recommendations
[Specific recommendations for improvement]

## Observability & Metrics
[Monitoring, logging, and metrics information]

## Testing
[Testing strategy and coverage]

## Deployment
[Deployment requirements and configuration]

## Related Documentation
[Links to related documentation]

## Code References
[Key code locations and files]

## Next Steps
[Action items and future work]
```

## Usage Guidelines

### When to Use
- Documenting new services
- Updating existing service documentation
- Creating service-specific findings

### Required Sections
- Purpose
- Current Implementation
- Dependencies
- Missing Pieces & Risks
- Recommendations

### Optional Sections
- API Endpoints (for REST services)
- Data Models (for data-heavy services)
- Observability & Metrics (for production services)
- Testing (for services with test coverage)
- Deployment (for services with specific deployment requirements)

### Formatting Standards
- Use consistent heading levels
- Include code blocks for configuration examples
- Use tables for structured data
- Add cross-references to related documentation
- Include timestamps for updates

### Maintenance
- Update when service implementation changes
- Review and update recommendations regularly
- Keep dependencies current
- Update status when service state changes
