# DevContainer Serverless Fullstack Template

A modern, opinionated, and extensible DevContainer template built for cloud, full-stack, DevOps, and infrastructure developers. Easily reproducible, portable, and ready for work in seconds.

## Key Features

### Intelligent Project Initialization
- **One-command setup** with `make init` - automatically configures your entire development environment
- **Dynamic port management** - automatically finds and assigns available ports to prevent conflicts
- **Smart dependency detection** - verifies prerequisites and sets up components intelligently
- **Cross-platform compatibility** - works seamlessly on macOS, Linux, and Windows

### Development Stack
- **Shell Environment**: Zsh, Oh My Zsh, Powerlevel10k with syntax highlighting, autosuggestions, and opinionated configuration
- **Cloud Tools**: AWS CLI v2, Terraform + tfswitch, OpenTofu v1.6.2
- **Languages**: Node.js 20.11.1 (via nvm), Python 3.11.9 (via pyenv) with pipenv support
- **Frontend**: React 19.0.0, Vite 6.3.4, TypeScript 5.7.2, ESLint 9.22.0
- **Backend**: FastAPI with Python 3.11, Uvicorn server
- **Quality Tools**: Pre-commit hooks with global configuration option
- **Customizable Features**: Toggle each feature as needed with flags

### Installed Tools
`terraform`, `aws`, `node`, `npm`, `python`, `pip`, `pipenv`, `tofu`, `pre-commit`, `zsh`

### DevContainer Features
Custom features with configurable options:

- **Shell Environment**: Zsh with Oh My Zsh, Powerlevel10k theme, autosuggestions with yellow highlighting, syntax highlighting, and opinionated configuration
- **AWS CLI**: Version 2 with full AWS toolkit integration
- **Terraform**: Latest version with tfswitch support
- **Node.js**: Version 20.11.1 via nvm with npm package management
- **Python**: Version 3.11.9 via pyenv with pipenv support enabled
- **OpenTofu**: Version 1.6.2 for Terraform-compatible infrastructure management
- **Pre-commit**: Global configuration enabled for consistent code quality

### VS Code Extensions
Curated, enterprise-grade extensions included (30 total):

- **Cloud & Infrastructure**: `hashicorp.terraform`, `amazonwebservices.aws-toolkit-vscode`, `amazonwebservices.amazon-q-vscode`, `redhat.vscode-yaml`
- **Python Development**: `ms-python.python`, `ms-python.vscode-pylance`, `ms-python.black-formatter`, `ms-python.isort`, `ms-toolsai.jupyter`, `ms-python.debugpy`
- **Web Development**: `dbaeumer.vscode-eslint`, `esbenp.prettier-vscode`, `bradlc.vscode-tailwindcss`
- **Shell & DevOps**: `timonwong.shellcheck`, `foxundermoon.shell-format`
- **Containers**: `ms-azuretools.vscode-docker`
- **Collaboration**: `eamodio.gitlens`, `donjayamanne.githistory`, `ms-vsliveshare.vsliveshare`, `github.vscode-github-actions`
- **Documentation**: `bierner.markdown-mermaid`, `streetsidesoftware.code-spell-checker`
- **Remote Development**: `ms-vscode-remote.remote-containers`, `ms-vscode-remote.remote-ssh`, `ms-vscode-remote.remote-ssh-edit`, `ms-vscode-remote.remote-wsl`, `ms-vscode-remote.vscode-remote-extensionpack`
- **Productivity**: `visualstudioexptteam.vscodeintellicode`, `naumovs.color-highlight`, `ms-vscode.makefile-tools`

## Quick Start

### Method 1: Complete Setup (Recommended)

1. **Clone this template:**
   ```bash
   gh repo create my-devcontainer --template jonmatum/devcontainer-serverless-fullstack-template
   cd my-devcontainer
   ```

2. **Initialize the project (IMPORTANT):**
   ```bash
   make init
   ```
   
   This single command will:
   - Check system prerequisites
   - Scan and assign available ports automatically
   - Configure DevContainer settings
   - Set up frontend application with Vite + React
   - Verify all components are properly configured

3. **Start the development environment:**
   ```bash
   make up
   ```

4. **Open in VS Code:**
   - Use `Dev Containers: Reopen in Container` from the Command Palette
   - Your development environment is ready!

### Method 2: Manual DevContainer Setup

1. Clone the template
2. Run `make init` to initialize the project configuration
3. Open in Visual Studio Code
4. Use `Dev Containers: Reopen in Container` from the Command Palette

## Why `make init` is Essential

### The Problem It Solves

Without proper initialization, you might encounter:
- **Port conflicts** when multiple projects try to use the same ports (3000, 8000, etc.)
- **Configuration mismatches** between DevContainer settings and actual services
- **Missing dependencies** that cause services to fail silently
- **Manual setup overhead** requiring multiple commands and configuration steps

### What `make init` Does

```bash
>> Starting Complete Project Initialization

[INFO]     Checking system prerequisites...
[SUCCESS]  Prerequisites check completed

[INFO]     Scanning for available ports...
[SUCCESS]  Assigned ports: Frontend(3000) Backend(3001) Admin(3002) DynamoDB(3003)

[INFO]     Rendering devcontainer configuration...
[SUCCESS]  DevContainer configuration rendered

[INFO]     Setting up frontend application...
[SUCCESS]  Frontend application configured

[INFO]     Verifying frontend setup...
[SUCCESS]  Frontend verification passed

[SUCCESS]  Project initialization completed successfully!
```

### Dynamic Port Assignment

The system intelligently manages ports to prevent conflicts:

- **Automatic Detection**: Scans your system for available ports starting from 3000 (configurable via `PORT_START`)
- **Conflict Resolution**: Uses `lsof` to detect port usage and automatically assigns next available port
- **Service Mapping**: 
  - Frontend (React/Vite): First available port (FPORT)
  - Backend (FastAPI): Second available port (BPORT = FPORT+1)  
  - DynamoDB Admin: Third available port (APORT = BPORT+1)
  - DynamoDB Local: Fourth available port (DPORT = APORT+1)
- **DevContainer Sync**: Automatically updates `.devcontainer/devcontainer.json` with assigned ports
- **Environment Variables**: Creates `.env` file with port assignments for consistent usage
- **Hardcoded Forward Ports**: DevContainer forwards ports 3005-3008 by default

### Port Assignment Example

```bash
# If ports 3000-3002 are busy, the system might assign:
FRONTEND_PORT=3003   # React development server
BACKEND_PORT=3004    # FastAPI server  
ADMIN_PORT=3005      # DynamoDB Admin interface
DYNAMODB_PORT=3006   # DynamoDB Local database
```

### Benefits of Dynamic Port Management

1. **Zero Configuration Conflicts**: Never worry about port collisions with other projects
2. **Team Consistency**: Every developer gets the same relative port assignments
3. **CI/CD Friendly**: Works in any environment without manual port configuration
4. **Multi-Project Support**: Run multiple instances of this template simultaneously
5. **Automatic Documentation**: Port assignments are clearly displayed and saved

## Available Commands

Run `make help` to see all available commands with detailed descriptions:

```bash
make help      # Show comprehensive help with command categories
make status    # Display current project status and port assignments
make init      # Complete project initialization (recommended first step)
make up        # Start all containers
make down      # Stop all containers
make logs      # Follow container logs
make clean     # Clean up Docker resources
```

### Command Categories (24 total commands)

- **Initialization & Setup**: Project initialization and configuration
- **Component Setup**: Individual component management  
- **Container Management**: Docker and container orchestration
- **DevContainer Operations**: DevContainer CLI integration
- **Maintenance & Cleanup**: System cleanup and maintenance
- **Utilities & Diagnostics**: Debugging and validation tools

### Project Status Monitoring

Use `make status` to get a comprehensive overview of your project:

```bash
>> Project Status Report

Port Configuration
  Frontend:    3000
  Backend:     3001
  Admin:       3002
  DynamoDB:    3003

Configuration Status
  DevContainer: Configured
  Environment:  Configured

Component Status
  Frontend:    Initialized
  Backend:     Available
```

## Services Overview

This template includes the following services:

- **DevContainer**: Main development environment with all tools
- **Frontend**: React 19.0.0 application with Vite 6.3.4 and TypeScript 5.7.2 (dynamically assigned port, starts from 3000)
- **Backend**: FastAPI Python 3.11 application with Uvicorn server (dynamically assigned port, typically 3001)
- **DynamoDB Local**: Local DynamoDB instance for development (dynamically assigned port, typically 3003)
- **DynamoDB Admin**: Web interface for DynamoDB management (dynamically assigned port, typically 3002)

**Note**: All service ports are dynamically assigned to prevent conflicts. The DevContainer also forwards ports 3005-3008 by default.

## Advanced Usage

### Custom Port Range
You can specify a custom starting port:
```bash
PORT_START=4000 make init
```

### Quick Setup (Ports Only)
For faster setup when you only need port configuration:
```bash
make init-quick
```

### Port Conflict Resolution
If you encounter port conflicts after initialization:
```bash
make find-ports  # Reassign to new available ports
make check-ports # Check current port availability
```

### Configuration Validation
Verify your setup is correct:
```bash
make validate-config
```

### Component Management
Initialize or reset individual components:
```bash
make init-frontend   # Set up React frontend
make init-backend    # Set up FastAPI backend
make reset-frontend  # Reset frontend (removes app directory)
make reset-backend   # Reset backend (removes Pipfile)
```

## Troubleshooting

### Common Issues

**Port conflicts during startup:**
```bash
make check-ports  # Check which ports are in use
make find-ports   # Reassign to available ports
make up           # Restart with new ports
```

**DevContainer configuration issues:**
```bash
make validate-config  # Verify all configurations
make init            # Reinitialize if needed
```

**Service not accessible:**
```bash
make status  # Check service status and port assignments
make logs    # View container logs for errors
```

## Customization

You can modify `devcontainer.json` to:

- Enable/disable features
- Change tool versions
- Add your own custom VS Code extensions
- Modify container configurations

The Makefile system will automatically adapt to your changes while maintaining port management and initialization capabilities.

## License

This project is licensed under the [MIT License](LICENSE).

---

> echo 'Pura Vida & Happy Coding!';
