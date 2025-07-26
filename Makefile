# ==============================================================================
# DevContainer Developer Workspace Makefile
# ==============================================================================
# A comprehensive build system for managing a full-stack development environment
# with automatic port management, container orchestration, and project setup.
#
# Quick Start:
#   make init    - Initialize the entire project
#   make up      - Start all containers
#   make status  - Check project status
#   make help    - Show all available commands
# ==============================================================================

.DEFAULT_GOAL := help
.PHONY: help init status up down clean

# Configuration
PORT_START ?= 3000
DC_CLI ?= devcontainer
COMPOSE_FILES := -f docker-compose.yml -f .devcontainer/docker-compose.override.yml

# Platform Detection
OS := $(shell uname -s)
ifeq ($(OS),Darwin)
	PLATFORM := macOS
else ifeq ($(OS),Linux)
	PLATFORM := Linux
else
	PLATFORM := Windows
endif

# Colors and Formatting
RESET := \033[0m
BOLD := \033[1m
DIM := \033[2m

# Status Colors
INFO := \033[1;34m
SUCCESS := \033[1;32m
WARN := \033[1;33m
ERROR := \033[1;31m

# UI Colors
HEADER := \033[1;36m
SECTION := \033[1;35m
COMMAND := \033[1;37m
DESCRIPTION := \033[0;37m

# Command Categories
CATEGORIES := init setup docker devcontainer maintenance utilities

# ==============================================================================
# HELP SYSTEM
# ==============================================================================

help: ## Show this help message with detailed command descriptions
	@echo ""
	@printf "$(HEADER)╔══════════════════════════════════════════════════════════════════════════════╗$(RESET)\n"
	@bash -c ' \
		TITLE_TEXT="DevContainer Developer Workspace"; \
		TOTAL_WIDTH=78; \
		TEXT_WIDTH=$${#TITLE_TEXT}; \
		LEFT_PADDING=$$((($${TOTAL_WIDTH} - $${TEXT_WIDTH}) / 2)); \
		RIGHT_PADDING=$$(($${TOTAL_WIDTH} - $${LEFT_PADDING} - $${TEXT_WIDTH})); \
		printf "$(HEADER)║%*s%s%*s║$(RESET)\n" $$LEFT_PADDING "" "$$TITLE_TEXT" $$RIGHT_PADDING ""; \
	'
	@bash -c ' \
		PLATFORM_TEXT="Platform: $(PLATFORM)"; \
		TOTAL_WIDTH=78; \
		TEXT_WIDTH=$${#PLATFORM_TEXT}; \
		LEFT_PADDING=27; \
		RIGHT_PADDING=$$((TOTAL_WIDTH - LEFT_PADDING - TEXT_WIDTH)); \
		if [ $$RIGHT_PADDING -lt 1 ]; then \
			RIGHT_PADDING=1; \
			LEFT_PADDING=$$((TOTAL_WIDTH - TEXT_WIDTH - RIGHT_PADDING)); \
		fi; \
		printf "$(HEADER)║%*s%s%*s║$(RESET)\n" $$LEFT_PADDING "" "$$PLATFORM_TEXT" $$RIGHT_PADDING ""; \
	'
	@printf "$(HEADER)╚══════════════════════════════════════════════════════════════════════════════╝$(RESET)\n"
	@echo ""
	@printf "$(DESCRIPTION)A comprehensive development environment with automatic port management,$(RESET)\n"
	@printf "$(DESCRIPTION)container orchestration, and full-stack project setup capabilities.$(RESET)\n"
	@echo ""
	@printf "$(COMMAND)USAGE:$(RESET)\n"
	@printf "  make $(BOLD)<command>$(RESET)\n"
	@echo ""
	@printf "$(COMMAND)QUICK START:$(RESET)\n"
	@printf "  $(SUCCESS)make init$(RESET)    Initialize project (ports, config, dependencies)\n"
	@printf "  $(SUCCESS)make up$(RESET)      Start all containers\n"
	@printf "  $(SUCCESS)make status$(RESET)  Check current project status\n"
	@echo ""
	@$(call render_help_sections)

define render_help_sections
	for category in $(CATEGORIES); do \
		case $$category in \
			init) \
				SECTION_NAME="Initialization & Setup"; \
				DESCRIPTION="Commands for project initialization and configuration"; \
				;; \
			setup) \
				SECTION_NAME="Component Setup"; \
				DESCRIPTION="Commands for setting up individual components"; \
				;; \
			docker) \
				SECTION_NAME="Container Management"; \
				DESCRIPTION="Docker and container orchestration commands"; \
				;; \
			devcontainer) \
				SECTION_NAME="DevContainer Operations"; \
				DESCRIPTION="DevContainer CLI integration commands"; \
				;; \
			maintenance) \
				SECTION_NAME="Maintenance & Cleanup"; \
				DESCRIPTION="System cleanup and maintenance commands"; \
				;; \
			utilities) \
				SECTION_NAME="Utilities & Diagnostics"; \
				DESCRIPTION="Utility commands for debugging and diagnostics"; \
				;; \
		esac; \
		printf "$(SECTION)$$SECTION_NAME$(RESET)\n"; \
		printf "$(DIM)$$DESCRIPTION$(RESET)\n\n"; \
		grep -E "^[a-zA-Z0-9_-]+:.*## \[$$category\]" $(MAKEFILE_LIST) | sort | \
			sed -E "s/:.*## \[$$category\] /|/" | \
			awk -F'|' '{printf "  $(SUCCESS)%-18s$(RESET) %s\n", $$1, $$2}'; \
		echo ""; \
	done
endef

# ==============================================================================
# INITIALIZATION COMMANDS
# ==============================================================================

init: ## [init] Complete project initialization with all dependencies
	@printf "$(HEADER)>> Starting Complete Project Initialization$(RESET)\n"
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Checking system prerequisites...\n"
	@command -v jq >/dev/null 2>&1 || { \
		printf "$(ERROR)[ERROR]$(RESET)    jq is required. Install: brew install jq (macOS) | apt install jq (Linux)\n"; \
		exit 1; \
	}
	@printf "$(SUCCESS)[SUCCESS]$(RESET)  Prerequisites check completed\n"
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Scanning for available ports...\n"
	@bash -c ' \
		find_free_port() { \
			port=$$1; \
			while lsof -i :$$port >/dev/null 2>&1; do \
				port=$$((port+1)); \
			done; \
			echo $$port; \
		}; \
		FPORT=$$(find_free_port $(PORT_START)); \
		BPORT=$$(find_free_port $$((FPORT+1))); \
		APORT=$$(find_free_port $$((BPORT+1))); \
		DPORT=$$(find_free_port $$((APORT+1))); \
		{ \
			echo "FRONTEND_PORT=$$FPORT"; \
			echo "BACKEND_PORT=$$BPORT"; \
			echo "ADMIN_PORT=$$APORT"; \
			echo "DYNAMODB_PORT=$$DPORT"; \
		} > .env; \
		printf "$(SUCCESS)[SUCCESS]$(RESET)  Assigned ports: Frontend($$FPORT) Backend($$BPORT) Admin($$APORT) DynamoDB($$DPORT)\n"; \
	'
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Rendering devcontainer configuration...\n"
	@if [ ! -f .devcontainer/devcontainer.template.json ]; then \
		printf "$(ERROR)[ERROR]$(RESET)    devcontainer.template.json not found\n"; \
		exit 1; \
	fi
	@cp .devcontainer/devcontainer.template.json .devcontainer/devcontainer.json
	@bash -c ' \
		set -a; source .env; set +a; \
		PORTS=$$(printf "%s\n" $$FRONTEND_PORT $$BACKEND_PORT $$ADMIN_PORT $$DYNAMODB_PORT | jq -s -c "map(tonumber)"); \
		sed -i.bak "s|\"forwardPorts\": \[\]|\"forwardPorts\": $$PORTS|g" .devcontainer/devcontainer.json; \
		rm -f .devcontainer/devcontainer.json.bak; \
	'
	@printf "$(SUCCESS)[SUCCESS]$(RESET)  DevContainer configuration rendered\n"
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Setting up frontend application...\n"
	@if [ ! -d frontend/app ]; then \
		mkdir -p frontend/app; \
		cd frontend/app && pnpm create vite@latest . --template react; \
	fi
	@mkdir -p frontend/app
	@printf "%s\n" \
		"import { defineConfig } from 'vite'" \
		"import react from '@vitejs/plugin-react'" \
		"" \
		"export default defineConfig({" \
		"  server: {" \
		"    host: '0.0.0.0'," \
		"    port: 3000," \
		"    strictPort: true," \
		"  }," \
		"  plugins: [react()]," \
		"});" > frontend/app/vite.config.js
	@printf "$(SUCCESS)[SUCCESS]$(RESET)  Frontend application configured\n"
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Verifying frontend setup...\n"
	@if [ ! -d frontend/app ] || [ ! -f frontend/app/package.json ]; then \
		printf "$(ERROR)[ERROR]$(RESET)    Frontend verification failed\n"; \
		exit 1; \
	fi
	@printf "$(SUCCESS)[SUCCESS]$(RESET)  Frontend verification passed\n"
	@echo ""
	@printf "$(SUCCESS)[SUCCESS]$(RESET)  Project initialization completed successfully!\n"
	@echo ""
	@printf "$(INFO)Next steps:$(RESET)\n"
	@printf "  1. Run '$(BOLD)make up$(RESET)' to start all containers\n"
	@printf "  2. Run '$(BOLD)make status$(RESET)' to verify everything is running\n"
	@echo ""

init-quick: ## [init] Quick initialization (ports and configuration only)
	@printf "$(HEADER)>> Starting Quick Initialization$(RESET)\n"
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Finding available ports...\n"
	@bash -c ' \
		find_free_port() { \
			port=$$1; \
			while lsof -i :$$port >/dev/null 2>&1; do \
				port=$$((port+1)); \
			done; \
			echo $$port; \
		}; \
		FPORT=$$(find_free_port $(PORT_START)); \
		BPORT=$$(find_free_port $$((FPORT+1))); \
		APORT=$$(find_free_port $$((BPORT+1))); \
		DPORT=$$(find_free_port $$((APORT+1))); \
		{ \
			echo "FRONTEND_PORT=$$FPORT"; \
			echo "BACKEND_PORT=$$BPORT"; \
			echo "ADMIN_PORT=$$APORT"; \
			echo "DYNAMODB_PORT=$$DPORT"; \
		} > .env; \
		printf "$(SUCCESS)[SUCCESS]$(RESET)  Ports assigned: $$FPORT, $$BPORT, $$APORT, $$DPORT\n"; \
	'
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Rendering devcontainer configuration...\n"
	@cp .devcontainer/devcontainer.template.json .devcontainer/devcontainer.json
	@bash -c ' \
		set -a; source .env; set +a; \
		PORTS=$$(printf "%s\n" $$FRONTEND_PORT $$BACKEND_PORT $$ADMIN_PORT $$DYNAMODB_PORT | jq -s -c "map(tonumber)"); \
		sed -i.bak "s|\"forwardPorts\": \[\]|\"forwardPorts\": $$PORTS|g" .devcontainer/devcontainer.json; \
		rm -f .devcontainer/devcontainer.json.bak; \
	'
	@printf "$(SUCCESS)[SUCCESS]$(RESET)  Configuration completed\n"
	@echo ""

status: ## [init] Display comprehensive project status and diagnostics
	@printf "$(HEADER)>> Project Status Report$(RESET)\n"
	@echo ""
	@printf "$(SECTION)Port Configuration$(RESET)\n"
	@if [ -f .env ]; then \
		source .env; \
		printf "  %-12s $(SUCCESS)%s$(RESET)\n" "Frontend:" "$$FRONTEND_PORT"; \
		printf "  %-12s $(SUCCESS)%s$(RESET)\n" "Backend:" "$$BACKEND_PORT"; \
		printf "  %-12s $(SUCCESS)%s$(RESET)\n" "Admin:" "$$ADMIN_PORT"; \
		printf "  %-12s $(SUCCESS)%s$(RESET)\n" "DynamoDB:" "$$DYNAMODB_PORT"; \
	else \
		printf "  $(ERROR)No port configuration found$(RESET)\n"; \
	fi
	@echo ""
	@printf "$(SECTION)Configuration Status$(RESET)\n"
	@if [ -f .devcontainer/devcontainer.json ]; then \
		printf "  %-12s $(SUCCESS)Configured$(RESET)\n" "DevContainer:"; \
	else \
		printf "  %-12s $(ERROR)Not Found$(RESET)\n" "DevContainer:"; \
	fi
	@if [ -f .env ]; then \
		printf "  %-12s $(SUCCESS)Configured$(RESET)\n" "Environment:"; \
	else \
		printf "  %-12s $(ERROR)Not Found$(RESET)\n" "Environment:"; \
	fi
	@echo ""
	@printf "$(SECTION)Component Status$(RESET)\n"
	@if [ -d frontend/app ]; then \
		printf "  %-12s $(SUCCESS)Initialized$(RESET)\n" "Frontend:"; \
	else \
		printf "  %-12s $(ERROR)Not Initialized$(RESET)\n" "Frontend:"; \
	fi
	@if docker compose ps backend >/dev/null 2>&1; then \
		printf "  %-12s $(SUCCESS)Available$(RESET)\n" "Backend:"; \
	else \
		printf "  %-12s $(WARN)Container Not Running$(RESET)\n" "Backend:"; \
	fi
	@echo ""

# ==============================================================================
# COMPONENT SETUP COMMANDS
# ==============================================================================

init-backend: ## [setup] Initialize backend dependencies inside container
	@printf "$(HEADER)>> Initializing Backend Dependencies$(RESET)\n"
	@echo ""
	@if ! docker compose ps backend | grep -q "Up"; then \
		printf "$(ERROR)[ERROR]$(RESET)    Backend container is not running. Run 'make up' first.\n"; \
		exit 1; \
	fi
	@printf "$(INFO)[INFO]$(RESET)     Installing backend dependencies...\n"
	docker compose exec backend /entrypoint.sh install
	@printf "$(SUCCESS)[SUCCESS]$(RESET)  Backend dependencies initialized\n"
	@echo ""

init-frontend: ## [setup] Initialize and configure frontend application
	@printf "$(HEADER)>> Initializing Frontend Application$(RESET)\n"
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Setting up frontend application...\n"
	@if [ ! -d frontend/app ]; then \
		mkdir -p frontend/app; \
		cd frontend/app && pnpm create vite@latest . --template react; \
	fi
	@mkdir -p frontend/app
	@printf "%s\n" \
		"import { defineConfig } from 'vite'" \
		"import react from '@vitejs/plugin-react'" \
		"" \
		"export default defineConfig({" \
		"  server: {" \
		"    host: '0.0.0.0'," \
		"    port: 3000," \
		"    strictPort: true," \
		"  }," \
		"  plugins: [react()]," \
		"});" > frontend/app/vite.config.js
	@printf "$(SUCCESS)[SUCCESS]$(RESET)  Frontend application initialized\n"
	@echo ""

reset-backend: ## [setup] Reset backend (removes Pipfile and reinstalls dependencies)
	@printf "$(HEADER)>> Resetting Backend Environment$(RESET)\n"
	@echo ""
	@printf "$(WARN)[WARNING]$(RESET) This will delete backend/Pipfile and Pipfile.lock\n"
	@printf "Are you sure you want to continue? [y/N]: "; \
	read -r confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		rm -f backend/Pipfile backend/Pipfile.lock; \
		printf "$(INFO)[INFO]$(RESET)     Removed existing Python dependencies\n"; \
		docker compose exec backend /entrypoint.sh install; \
		printf "$(SUCCESS)[SUCCESS]$(RESET)  Backend reset completed\n"; \
	else \
		printf "$(INFO)[INFO]$(RESET)     Backend reset cancelled\n"; \
	fi
	@echo ""

reset-frontend: ## [setup] Reset frontend application (removes app directory)
	@printf "$(HEADER)>> Resetting Frontend Application$(RESET)\n"
	@echo ""
	@printf "$(WARN)[WARNING]$(RESET) This will delete the frontend/app directory\n"
	@printf "Are you sure you want to continue? [y/N]: "; \
	read -r confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		rm -rf frontend/app; \
		printf "$(INFO)[INFO]$(RESET)     Removed existing frontend application\n"; \
		$(MAKE) init-frontend; \
		printf "$(SUCCESS)[SUCCESS]$(RESET)  Frontend reset completed\n"; \
	else \
		printf "$(INFO)[INFO]$(RESET)     Frontend reset cancelled\n"; \
	fi
	@echo ""

# ==============================================================================
# CONTAINER MANAGEMENT COMMANDS
# ==============================================================================

build: ## [docker] Build all Docker containers
	@printf "$(HEADER)>> Building Docker Containers$(RESET)\n"
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Building all containers...\n"
	docker compose $(COMPOSE_FILES) build
	@printf "$(SUCCESS)[SUCCESS]$(RESET)  All containers built successfully\n"
	@echo ""

up: ## [docker] Start all containers with automatic initialization
	@printf "$(HEADER)>> Starting Development Environment$(RESET)\n"
	@echo ""
	@if [ ! -f .env ]; then \
		printf "$(INFO)[INFO]$(RESET)     Environment not configured, running quick initialization...\n"; \
		$(MAKE) init-quick; \
		echo ""; \
	fi
	@$(call check_port_conflicts)
	@printf "$(INFO)[INFO]$(RESET)     Starting all containers...\n"
	docker compose $(COMPOSE_FILES) up -d
	@echo ""
	@printf "$(SUCCESS)[SUCCESS]$(RESET)  Development environment started\n"
	@$(call show_running_services)

down: ## [docker] Stop all containers gracefully
	@printf "$(HEADER)>> Stopping Development Environment$(RESET)\n"
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Stopping all containers...\n"
	docker compose $(COMPOSE_FILES) down
	@printf "$(SUCCESS)[SUCCESS]$(RESET)  All containers stopped\n"
	@echo ""

restart: ## [docker] Restart all containers (stop, build, start)
	@printf "$(HEADER)>> Restarting Development Environment$(RESET)\n"
	@echo ""
	@$(MAKE) down
	@$(MAKE) build
	@$(MAKE) up

logs: ## [docker] Follow logs from all containers
	@printf "$(HEADER)>> Streaming Container Logs$(RESET)\n"
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Press Ctrl+C to stop following logs\n"
	@echo ""
	docker compose $(COMPOSE_FILES) logs -f

# ==============================================================================
# DEVCONTAINER OPERATIONS
# ==============================================================================

dc-build: ## [devcontainer] Build using DevContainer CLI
	$(call log_step, "Building with DevContainer CLI")
	$(DC_CLI) build
	$(call log_success, "DevContainer build completed")

dc-up: ## [devcontainer] Start using DevContainer CLI
	$(call log_step, "Starting with DevContainer CLI")
	$(DC_CLI) up
	$(call log_success, "DevContainer started")

dc-down: ## [devcontainer] Stop using DevContainer CLI
	$(call log_step, "Stopping DevContainer")
	$(DC_CLI) down
	$(call log_success, "DevContainer stopped")

# ==============================================================================
# MAINTENANCE COMMANDS
# ==============================================================================

clean: ## [maintenance] Remove stopped containers and dangling images
	$(call log_step, "Cleaning Docker Resources")
	docker system prune -f
	$(call log_success, "Docker cleanup completed")

clean-volumes: ## [maintenance] Remove unused volumes (WARNING: deletes data)
	$(call log_step, "Cleaning Docker Volumes")
	@printf "$(WARN)[WARNING]$(RESET) This will delete all unused Docker volumes including databases\n"
	@printf "Are you sure you want to continue? [y/N]: "; \
	read -r confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		docker volume prune -f; \
		$(call log_success, "Volume cleanup completed"); \
	else \
		$(call log_info, "Volume cleanup cancelled"); \
	fi

nuke: ## [maintenance] Nuclear option - remove everything (containers, images, volumes)
	$(call log_step, "Nuclear Cleanup - Removing Everything")
	@printf "$(ERROR)[DANGER]$(RESET) This will remove ALL containers, images, and volumes\n"
	@printf "Are you sure you want to continue? [y/N]: "; \
	read -r confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		docker compose $(COMPOSE_FILES) down -v --remove-orphans; \
		docker system prune -a --volumes -f; \
		$(call log_success, "Nuclear cleanup completed"); \
	else \
		$(call log_info, "Nuclear cleanup cancelled"); \
	fi

rebuild: ## [maintenance] Rebuild all containers without cache
	$(call log_step, "Rebuilding All Containers")
	docker compose $(COMPOSE_FILES) build --no-cache
	$(call log_success, "All containers rebuilt")

reset-all: ## [maintenance] Complete reset (clean volumes, rebuild, start)
	$(call log_step, "Complete Environment Reset")
	@$(MAKE) down
	@$(MAKE) clean-volumes
	@$(MAKE) rebuild
	@$(MAKE) up

# ==============================================================================
# UTILITY COMMANDS
# ==============================================================================

check-ports: ## [utilities] Check availability of configured ports
	@printf "$(HEADER)>> Checking Port Availability$(RESET)\n"
	@echo ""
	@$(call check_port_conflicts)
	@echo ""

find-ports: ## [utilities] Find and assign new available ports
	@printf "$(HEADER)>> Finding Available Ports$(RESET)\n"
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Scanning for available ports...\n"
	@bash -c ' \
		find_free_port() { \
			port=$$1; \
			while lsof -i :$$port >/dev/null 2>&1; do \
				port=$$((port+1)); \
			done; \
			echo $$port; \
		}; \
		FPORT=$$(find_free_port $(PORT_START)); \
		BPORT=$$(find_free_port $$((FPORT+1))); \
		APORT=$$(find_free_port $$((BPORT+1))); \
		DPORT=$$(find_free_port $$((APORT+1))); \
		{ \
			echo "FRONTEND_PORT=$$FPORT"; \
			echo "BACKEND_PORT=$$BPORT"; \
			echo "ADMIN_PORT=$$APORT"; \
			echo "DYNAMODB_PORT=$$DPORT"; \
		} > .env; \
		printf "$(SUCCESS)[SUCCESS]$(RESET)  New ports assigned: $$FPORT, $$BPORT, $$APORT, $$DPORT\n"; \
	'
	@echo ""


validate-config: ## [utilities] Validate all configuration files
	@printf "$(HEADER)>> Validating Configuration$(RESET)\n"
	@echo ""
	@printf "$(INFO)[INFO]$(RESET)     Validating Docker Compose configuration...\n"
	@docker compose $(COMPOSE_FILES) config >/dev/null
	@printf "$(INFO)[INFO]$(RESET)     Validating DevContainer configuration...\n"
	@if [ -f .devcontainer/devcontainer.json ]; then \
		jq empty .devcontainer/devcontainer.json >/dev/null; \
	fi
	@printf "$(INFO)[INFO]$(RESET)     Validating environment configuration...\n"
	@if [ -f .env ]; then \
		source .env; \
		[ -n "$$FRONTEND_PORT" ] && [ -n "$$BACKEND_PORT" ] && [ -n "$$ADMIN_PORT" ] && [ -n "$$DYNAMODB_PORT" ]; \
	fi
	@printf "$(SUCCESS)[SUCCESS]$(RESET)  Configuration validation completed\n"
	@echo ""

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

define check_port_conflicts
	@if [ ! -f .env ]; then \
		printf "$(ERROR)[ERROR]$(RESET) Environment file not found\n"; \
		exit 1; \
	fi
	@bash -c ' \
		source .env; \
		conflicts=0; \
		for port in $$FRONTEND_PORT $$BACKEND_PORT $$ADMIN_PORT $$DYNAMODB_PORT; do \
			if lsof -i :$$port >/dev/null 2>&1; then \
				printf "$(WARN)[WARN]$(RESET) Port $$port is in use\n"; \
				conflicts=$$((conflicts+1)); \
			fi; \
		done; \
		if [ $$conflicts -gt 0 ]; then \
			printf "$(WARN)Found $$conflicts port conflicts. Run '\''make find-ports'\'' to reassign$(RESET)\n"; \
		fi \
	'
endef

define show_running_services
	@echo ""
	@printf "$(SECTION)Running Services$(RESET)\n"
	@if [ -f .env ]; then \
		source .env; \
		printf "  %-12s $(INFO)%s$(RESET)\n" "Frontend:" "http://localhost:$$FRONTEND_PORT"; \
		printf "  %-12s $(INFO)%s$(RESET)\n" "Backend:" "http://localhost:$$BACKEND_PORT"; \
		printf "  %-12s $(INFO)%s$(RESET)\n" "Admin:" "http://localhost:$$ADMIN_PORT"; \
		printf "  %-12s $(INFO)%s$(RESET)\n" "DynamoDB:" "http://localhost:$$DYNAMODB_PORT"; \
	fi
	@echo ""
endef
