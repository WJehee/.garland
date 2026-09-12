
# Lint dependencies: advisories, licenses, duplicate versions, sources
deny:
    cargo deny check

# Check every dependency is covered by a trusted audit, import or exemption
vet:
    cargo vet

# Rank unaudited dependencies by the effort needed to clear them
vet-suggest:
    cargo vet suggest

# List who can publish each dependency to crates.io
publishers:
    cargo supply-chain publishers

# Run all supply chain checks
supply-chain: deny vet
