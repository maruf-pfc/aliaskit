# Contributing to Aliaskit

First off, thanks for taking the time to contribute! 🎉

Aliaskit is an open-source project and we love receiving contributions from our community — you can contribute in many ways:
- Creating new `modules` for different tools.
- Fixing bugs or improving existing aliases.
- Enhancing the core documentation and CLI engine.

## Development Setup

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/aliaskit.git
   cd aliaskit
   ```
3. Initialize the environment:
   ```bash
   export AK_ROOT="$(pwd)"
   source core/init.sh
   ```

## Adding a New Module

If you are adding a new domain of aliases (e.g., `kubernetes`), create a new file in the `modules/` directory following the numerical prefix convention.

```bash
#!/usr/bin/env bash
# CATEGORY: Kubernetes
# MODULE: kubernetes

## k
# @desc  Kubernetes CLI wrapper
# @usage k <command>
# @example k get pods
alias k='kubectl'
```

## Pull Request Guidelines

Before you submit a Pull Request (PR), please verify that:
- Your Bash code passes `shellcheck`. You can run it locally: `shellcheck my_script.sh`.
- You have added descriptions `# @desc` to all new aliases.
- You have filled out the standard PR template.

We look forward to reviewing your PR!
