# ==============================================================================
# Claude DevContainer Makefile
# ==============================================================================
# A Docker-based development environment for Claude Code
#
# Usage:
#   make dev              - Complete setup, build, and start
#   make setup-claude     - Setup environment from template
#   make start-dev        - Start existing container
#   make exec-dev         - Connect to running container
#   make help             - Show detailed help
#
# Variables:
#   SOURCE_DIR   - Path to template directory
#
# ==============================================================================
# Variables
# ==============================================================================
# To be set by the user: absolute path of Claude-DevContainer 
SOURCE_DIR := /home/seagull/Applications/Claude-DevContainer

# Project and container settings
PROJECT_NAME := $(shell basename $(PWD))
CONTAINER_NAME := claude-dev-$(shell echo $(PROJECT_NAME) | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$$//')

# Directory paths
DEVCONTAINER_DIR := .devcontainer
COMPOSE_FILE := $(DEVCONTAINER_DIR)/docker-compose.yml
ENV_FILE := $(DEVCONTAINER_DIR)/.env

# ==============================================================================
# PHONY targets
# ==============================================================================
.PHONY: build-devcontainer start-dev stop-dev exec-dev clean-dev help \
	restart-dev logs-dev status-dev rebuild-dev setup-claude \
	setup-and-build dev check-docker list-containers update-template

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Help target
help:
	@if [ -z "$(TARGET)" ]; then \
		echo "$(BLUE)Claude DevContainer Makefile$(NC)"; \
		echo ""; \
		echo "$(GREEN)Usage:$(NC)"; \
		echo "  make <target>                - Run a specific target"; \
		echo "  make help TARGET=<target>    - Show detailed help for a specific target"; \
		echo ""; \
		echo "$(GREEN)Logical workflow sequence:$(NC)"; \
		echo "  1. Setup     -> 2. Build     -> 3. Start     -> 4. Use     -> 5. Stop/Clean"; \
		echo ""; \
		echo "$(BLUE)=== SETUP COMMANDS ===$(NC)"; \
		echo "  $(YELLOW)setup-claude$(NC)        - Setup Claude environment from template"; \
		echo "  $(YELLOW)setup-and-build$(NC)     - Setup Claude environment and build container"; \
		echo "  $(YELLOW)dev$(NC)                 - Complete development environment setup (setup + build + start)"; \
		echo "  $(YELLOW)update-template$(NC)     - Update template from current project (reverse sync)"; \
		echo ""; \
		echo "$(BLUE)=== BUILD COMMANDS ===$(NC)"; \
		echo "  $(YELLOW)build-devcontainer$(NC)  - Build or rebuild the devcontainer"; \
		echo "  $(YELLOW)rebuild-dev$(NC)         - Rebuild from scratch (clean + build + start)"; \
		echo ""; \
		echo "$(BLUE)=== CONTAINER MANAGEMENT ===$(NC)"; \
		echo "  $(YELLOW)start-dev$(NC)           - Start the devcontainer"; \
		echo "  $(YELLOW)stop-dev$(NC)            - Stop the devcontainer"; \
		echo "  $(YELLOW)restart-dev$(NC)         - Restart the devcontainer"; \
		echo "  $(YELLOW)exec-dev$(NC)            - Execute shell in devcontainer"; \
		echo "  $(YELLOW)logs-dev$(NC)            - Show container logs"; \
		echo "  $(YELLOW)status-dev$(NC)          - Show container status"; \
		echo ""; \
		echo "$(BLUE)=== CLEANUP COMMANDS ===$(NC)"; \
		echo "  $(YELLOW)clean-dev$(NC)           - Remove container and volumes"; \
		echo "  $(YELLOW)list-containers$(NC)     - List all Claude devcontainers"; \
		echo ""; \
		echo "$(BLUE)=== UTILITY COMMANDS ===$(NC)"; \
		echo "  $(YELLOW)check-docker$(NC)        - Check if Docker is running"; \
		echo "  $(YELLOW)help$(NC)                - Show this help message"; \
		echo ""; \
		echo "$(GREEN)Examples:$(NC)"; \
		echo "  make dev                      - Complete setup and start development environment"; \
		echo "  make setup-claude              - Just setup the environment without building"; \
		echo "  make start-dev                 - Start existing container"; \
		echo "  make exec-dev                  - Connect to running container"; \
		echo "  make stop-dev                  - Stop the container"; \
		echo "  make help TARGET=start-dev     - Show detailed help for start-dev target"; \
	else \
		echo "$(BLUE)Detailed help for target: $(TARGET)$(NC)"; \
		echo ""; \
		case "$(TARGET)" in \
			setup-claude) \
				echo "$(GREEN)Name:$(NC) setup-claude"; \
				echo "$(GREEN)Description:$(NC) Copies template files and sets up environment"; \
				echo "$(GREEN)Usage:$(NC) make setup-claude"; \
				echo "$(GREEN)Source:$(NC) $(SOURCE_DIR)"; \
				echo "$(GREEN)Example:$(NC) make setup-claude"; \
				;; \
			setup-and-build) \
				echo "$(GREEN)Name:$(NC) setup-and-build"; \
				echo "$(GREEN)Description:$(NC) Sets up environment and builds the container"; \
				echo "$(GREEN)Usage:$(NC) make setup-and-build"; \
				echo "$(GREEN)Example:$(NC) make setup-and-build"; \
				;; \
			dev) \
				echo "$(GREEN)Name:$(NC) dev"; \
				echo "$(GREEN)Description:$(NC) Complete setup: copies files, builds, and starts container"; \
				echo "$(GREEN)Usage:$(NC) make dev"; \
				echo "$(GREEN)Example:$(NC) make dev"; \
				;; \
			update-template) \
				echo "$(GREEN)Name:$(NC) update-template"; \
				echo "$(GREEN)Description:$(NC) Updates the source template with current project files"; \
				echo "$(GREEN)Usage:$(NC) make update-template"; \
				echo "$(GREEN)Warning:$(NC) This will overwrite your template"; \
				echo "$(GREEN)Example:$(NC) make update-template"; \
				;; \
			build-devcontainer) \
				echo "$(GREEN)Name:$(NC) build-devcontainer"; \
				echo "$(GREEN)Description:$(NC) Builds the devcontainer Docker image"; \
				echo "$(GREEN)Usage:$(NC) make build-devcontainer"; \
				echo "$(GREEN)Dependencies:$(NC) Requires docker-compose.yml to exist"; \
				echo "$(GREEN)Example:$(NC) make build-devcontainer"; \
				;; \
			rebuild-dev) \
				echo "$(GREEN)Name:$(NC) rebuild-dev"; \
				echo "$(GREEN)Description:$(NC) Rebuilds from scratch (clean + build + start)"; \
				echo "$(GREEN)Usage:$(NC) make rebuild-dev"; \
				echo "$(GREEN)Example:$(NC) make rebuild-dev"; \
				;; \
			start-dev) \
				echo "$(GREEN)Name:$(NC) start-dev"; \
				echo "$(GREEN)Description:$(NC) Starts the devcontainer in detached mode"; \
				echo "$(GREEN)Usage:$(NC) make start-dev"; \
				echo "$(GREEN)Dependencies:$(NC) Requires .env file with CONTAINER_NAME"; \
				echo "$(GREEN)Example:$(NC) make start-dev"; \
				;; \
			stop-dev) \
				echo "$(GREEN)Name:$(NC) stop-dev"; \
				echo "$(GREEN)Description:$(NC) Stops the running devcontainer"; \
				echo "$(GREEN)Usage:$(NC) make stop-dev"; \
				echo "$(GREEN)Example:$(NC) make stop-dev"; \
				;; \
			restart-dev) \
				echo "$(GREEN)Name:$(NC) restart-dev"; \
				echo "$(GREEN)Description:$(NC) Restarts the devcontainer (stop + start)"; \
				echo "$(GREEN)Usage:$(NC) make restart-dev"; \
				echo "$(GREEN)Example:$(NC) make restart-dev"; \
				;; \
			exec-dev) \
				echo "$(GREEN)Name:$(NC) exec-dev"; \
				echo "$(GREEN)Description:$(NC) Opens a ZSH shell inside the running container"; \
				echo "$(GREEN)Usage:$(NC) make exec-dev"; \
				echo "$(GREEN)Dependencies:$(NC) Container must be running"; \
				echo "$(GREEN)Example:$(NC) make exec-dev"; \
				;; \
			logs-dev) \
				echo "$(GREEN)Name:$(NC) logs-dev"; \
				echo "$(GREEN)Description:$(NC) Shows and follows container logs"; \
				echo "$(GREEN)Usage:$(NC) make logs-dev"; \
				echo "$(GREEN)Example:$(NC) make logs-dev"; \
				;; \
			status-dev) \
				echo "$(GREEN)Name:$(NC) status-dev"; \
				echo "$(GREEN)Description:$(NC) Shows the current status of the devcontainer"; \
				echo "$(GREEN)Usage:$(NC) make status-dev"; \
				echo "$(GREEN)Example:$(NC) make status-dev"; \
				;; \
			clean-dev) \
				echo "$(GREEN)Name:$(NC) clean-dev"; \
				echo "$(GREEN)Description:$(NC) Stops and removes the container and volumes"; \
				echo "$(GREEN)Usage:$(NC) make clean-dev"; \
				echo "$(GREEN)Warning:$(NC) This will delete all container data"; \
				echo "$(GREEN)Example:$(NC) make clean-dev"; \
				;; \
			list-containers) \
				echo "$(GREEN)Name:$(NC) list-containers"; \
				echo "$(GREEN)Description:$(NC) Lists all Claude devcontainers on the system"; \
				echo "$(GREEN)Usage:$(NC) make list-containers"; \
				echo "$(GREEN)Example:$(NC) make list-containers"; \
				;; \
			check-docker) \
				echo "$(GREEN)Name:$(NC) check-docker"; \
				echo "$(GREEN)Description:$(NC) Checks if Docker daemon is running"; \
				echo "$(GREEN)Usage:$(NC) make check-docker"; \
				echo "$(GREEN)Example:$(NC) make check-docker"; \
				;; \
			*) \
				echo "$(RED)Unknown target: $(TARGET)$(NC)"; \
				echo "$(YELLOW)Run 'make help' to see available targets$(NC)"; \
				;; \
		esac; \
		echo ""; \
	fi

check-docker:
	@docker info > /dev/null 2>&1 || (echo "$(RED)Docker is not running$(NC)" && exit 1)
	@echo "$(GREEN)Docker is running$(NC)"

build-devcontainer: check-docker
	@echo "$(BLUE)Building devcontainer...$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)Error: $(COMPOSE_FILE) not found$(NC)"; \
		echo "$(YELLOW)Run 'make setup-claude' first$(NC)"; \
		exit 1; \
	fi
	@cd $(DEVCONTAINER_DIR) && docker compose build
	@echo "$(GREEN)Devcontainer built successfully$(NC)"
	@echo "$(BLUE)Container will be named: $(CONTAINER_NAME)$(NC)"

start-dev: check-docker
	@echo "$(BLUE)Starting devcontainer...$(NC)"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo "$(RED)Error: $(COMPOSE_FILE) not found$(NC)"; \
		echo "$(YELLOW)Run 'make setup-claude' first$(NC)"; \
		exit 1; \
	fi
	@# Load CONTAINER_NAME from .env
	@if [ -f "$(ENV_FILE)" ]; then \
		echo "$(YELLOW)Loading configuration from $(ENV_FILE)$(NC)"; \
		export $$(grep -v '^#' $(ENV_FILE) | xargs); \
		CONTAINER_NAME=$$(grep "^CONTAINER_NAME=" $(ENV_FILE) | cut -d'=' -f2); \
		if [ -n "$$CONTAINER_NAME" ]; then \
			echo "$(BLUE)Using container name: $$CONTAINER_NAME$(NC)"; \
			if docker ps -a --format '{{.Names}}' | grep -q "^$$CONTAINER_NAME$$"; then \
				echo "$(YELLOW)Removing existing container: $$CONTAINER_NAME$(NC)"; \
				docker rm -f $$CONTAINER_NAME 2>/dev/null || true; \
			fi; \
			if docker ps -a --format '{{.Names}}' | grep -q "^claude-code-sandbox$$"; then \
				echo "$(YELLOW)Removing old container: claude-code-sandbox$(NC)"; \
				docker rm -f claude-code-sandbox 2>/dev/null || true; \
			fi; \
			export CONTAINER_NAME=$$CONTAINER_NAME; \
		fi; \
	fi
	@cd $(DEVCONTAINER_DIR) && docker compose up -d
	@echo "$(GREEN)Devcontainer started$(NC)"
	@if [ -f "$(ENV_FILE)" ]; then \
		CONTAINER_NAME=$$(grep "^CONTAINER_NAME=" $(ENV_FILE) | cut -d'=' -f2); \
		if [ -n "$$CONTAINER_NAME" ]; then \
			echo "$(BLUE)Container name: $$CONTAINER_NAME$(NC)"; \
		else \
			echo "$(YELLOW)Check container name with: docker ps --format 'table {{.Names}}' | grep claude$(NC)"; \
		fi; \
	fi
	@echo "$(YELLOW)To exec into container: make exec-dev$(NC)"

stop-dev:
	@echo "$(BLUE)Stopping devcontainer...$(NC)"
	@if [ -f "$(COMPOSE_FILE)" ]; then \
		cd $(DEVCONTAINER_DIR) && docker compose down; \
		echo "$(GREEN)Devcontainer stopped$(NC)"; \
	else \
		echo "$(YELLOW)No docker-compose.yml found$(NC)"; \
	fi

restart-dev: stop-dev start-dev

exec-dev: check-docker
	@echo "$(BLUE)Connecting to devcontainer...$(NC)"
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "$(RED)Error: $(ENV_FILE) not found$(NC)"; \
		echo "$(YELLOW)Run 'make setup-claude' first$(NC)"; \
		exit 1; \
	fi
	@CONTAINER_NAME=$$(grep "^CONTAINER_NAME=" $(ENV_FILE) | cut -d'=' -f2); \
	if [ -z "$$CONTAINER_NAME" ]; then \
		CONTAINER_NAME="claude-code-sandbox"; \
	fi; \
	if ! docker ps --format '{{.Names}}' | grep -q "^$$CONTAINER_NAME$$"; then \
		echo "$(RED)Container $$CONTAINER_NAME is not running$(NC)"; \
		echo "$(YELLOW)Run 'make start-dev' first$(NC)"; \
		exit 1; \
	fi; \
	echo "$(GREEN)Connecting to $$CONTAINER_NAME$(NC)"; \
	docker exec -it $$CONTAINER_NAME zsh

logs-dev: check-docker
	@if [ -f "$(COMPOSE_FILE)" ]; then \
		cd $(DEVCONTAINER_DIR) && docker compose logs -f; \
	else \
		echo "$(RED)No docker-compose.yml found$(NC)"; \
		exit 1; \
	fi

status-dev: check-docker
	@echo "$(BLUE)Devcontainer status:$(NC)"
	@if [ -f "$(ENV_FILE)" ]; then \
		CONTAINER_NAME=$$(grep "^CONTAINER_NAME=" $(ENV_FILE) | cut -d'=' -f2); \
		if [ -n "$$CONTAINER_NAME" ]; then \
			echo "$(YELLOW)Expected container: $$CONTAINER_NAME$(NC)"; \
			if docker ps --format '{{.Names}}' | grep -q "^$$CONTAINER_NAME$$"; then \
				echo "$(GREEN)Container $$CONTAINER_NAME is running$(NC)"; \
				docker ps --filter "name=$$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"; \
			else \
				echo "$(RED)Container $$CONTAINER_NAME is not running$(NC)"; \
				echo "$(YELLOW)Run 'make start-dev' to start it$(NC)"; \
			fi; \
		else \
			CONTAINER_NAME="claude-code-sandbox"; \
			echo "$(YELLOW)Using default container name: $$CONTAINER_NAME$(NC)"; \
		fi; \
	else \
		echo "$(RED)No .env found$(NC)"; \
	fi

clean-dev:
	@echo "$(RED)Cleaning up devcontainer...$(NC)"
	@if [ -f "$(COMPOSE_FILE)" ]; then \
		cd $(DEVCONTAINER_DIR) && docker compose down -v; \
		echo "$(GREEN)Container and volumes removed$(NC)"; \
	else \
		echo "$(YELLOW)No docker-compose.yml found$(NC)"; \
	fi

rebuild-dev: clean-dev build-devcontainer start-dev
	@echo "$(GREEN)Devcontainer rebuilt and started successfully$(NC)"

setup-claude:
	@echo "$(BLUE)Setting up Claude environment...$(NC)"
	@if [ ! -d "$(SOURCE_DIR)" ]; then \
		echo "$(RED)Error: Source directory $(SOURCE_DIR) not found$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Copying files from $(SOURCE_DIR)...$(NC)"
	@mkdir -p .claude .devcontainer
	@cp -a "$(SOURCE_DIR)/.claude/" . 2>/dev/null || echo "$(YELLOW)No .claude files to copy$(NC)"
	@cp -a "$(SOURCE_DIR)/.devcontainer" . 2>/dev/null || echo "$(YELLOW)No .devcontainer files to copy$(NC)"
	@echo "$(GREEN)Files copied successfully$(NC)"
	@# Generate dynamic container name
	@CONTAINER_NAME="claude-dev-$$(echo $(PROJECT_NAME) | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$$//')"; \
	if [ -f "$(ENV_FILE)" ]; then \
		echo "$(YELLOW)Updating container name in .env...$(NC)"; \
		sed -i '/^CONTAINER_NAME=/d' $(ENV_FILE); \
		echo "" >> $(ENV_FILE); \
		echo "CONTAINER_NAME=$$CONTAINER_NAME" >> $(ENV_FILE); \
		echo "$(GREEN)Container name set to: $$CONTAINER_NAME$(NC)"; \
	else \
		echo "$(YELLOW).env not found, creating it...$(NC)"; \
		echo "# Claude Dev Container Configuration" > $(ENV_FILE); \
		echo "# Generated by make setup-claude on $$(date)" >> $(ENV_FILE); \
		echo "" >> $(ENV_FILE); \
		echo "CONTAINER_NAME=$$CONTAINER_NAME" >> $(ENV_FILE); \
		echo "$(GREEN)Created .env with container name: $$CONTAINER_NAME$(NC)"; \
	fi
	@# Initialize/reinitialize git
	@if [ -d ".git" ]; then \
		read -p ".git folder already exists. Reinitialize (delete existing)? [y/N] - " -r answer; \
		if echo "$$answer" | grep -qi "^[yY]"; then \
			echo "$(YELLOW)Removing existing .git...$(NC)"; \
			rm -rf .git; \
			git init; \
			echo "$(GREEN)Git repository reinitialized$(NC)"; \
		else \
			echo "$(YELLOW)Skipping git initialization$(NC)"; \
		fi; \
	else \
		echo "$(YELLOW)Initializing git repository...$(NC)"; \
		git init; \
		echo "$(GREEN)Git repository initialized$(NC)"; \
	fi
	@echo "$(GREEN)Claude environment setup complete$(NC)"

setup-and-build: setup-claude build-devcontainer
	@echo "$(GREEN)Setup and build complete$(NC)"
	@echo "$(BLUE)Run 'make start-dev' to start the container$(NC)"

dev: setup-and-build start-dev
	@echo "$(GREEN)Development environment ready$(NC)"
	@echo "$(BLUE)Run 'make exec-dev' to connect$(NC)"

list-containers: check-docker
	@echo "$(BLUE)All Claude devcontainers:$(NC)"
	@docker ps -a --format "table {{.Names}}\t{{.Status}}" | grep "claude-dev" || echo "No Claude devcontainers found"

update-template:
	@echo "$(RED)This will overwrite your template with current project files$(NC)"
	@echo "$(YELLOW)Source: $(PWD)/.claude and $(PWD)/.devcontainer$(NC)"
	@echo "$(YELLOW)Target: $(SOURCE_DIR)/.claude and $(SOURCE_DIR)/.devcontainer$(NC)"
	@read -p "Are you sure? (y/n): " -n 1 -r; \
	echo; \
	if [ "$$REPLY" = "y" ] || [ "$$REPLY" = "Y" ]; then \
		if [ -d ".claude" ]; then \
			cp -a .claude/ $(SOURCE_DIR)/.claude/; \
			echo "$(GREEN)Updated .claude template$(NC)"; \
		else \
			echo "$(YELLOW)No .claude directory found$(NC)"; \
		fi; \
		if [ -d ".devcontainer" ]; then \
			cp -a .devcontainer/ $(SOURCE_DIR)/.devcontainer/; \
			echo "$(GREEN)Updated .devcontainer template$(NC)"; \
		else \
			echo "$(YELLOW)No .devcontainer directory found$(NC)"; \
		fi; \
		echo "$(GREEN)Template updated successfully$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

# Default target
all: help