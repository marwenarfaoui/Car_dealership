.PHONY: install clean test test-coverage lint build-debug build-release detox-build detox-test deploy help

help:
	@echo "MonApp - React Native Mobile Development Commands"
	@echo ""
	@echo "Setup & Installation:"
	@echo "  make install        - Install all dependencies"
	@echo "  make clean          - Clean build directories"
	@echo ""
	@echo "Testing:"
	@echo "  make test           - Run Jest unit tests"
	@echo "  make test-coverage  - Run tests with coverage report"
	@echo "  make lint           - Lint the codebase"
	@echo ""
	@echo "Building:"
	@echo "  make build-debug    - Build debug APK"
	@echo "  make build-release  - Build release AAB"
	@echo ""
	@echo "E2E Testing (requires Android emulator):"
	@echo "  make detox-build    - Build Detox test APK"
	@echo "  make detox-test     - Run E2E tests with Detox"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy         - Run complete deployment pipeline"
	@echo ""

install:
	@echo "Installing dependencies..."
	npm install

clean:
	@echo "Cleaning..."
	npm run clean
	cd android && ./gradlew clean
	rm -rf node_modules/.cache

test:
	@echo "Running unit tests..."
	npm test

test-coverage:
	@echo "Running tests with coverage..."
	npm run test:coverage

lint:
	@echo "Running linter..."
	npm run lint

build-debug:
	@echo "Building debug APK..."
	cd android && ./gradlew assembleDebug

build-release:
	@echo "Building release AAB..."
	npm run build:release

detox-build:
	@echo "Building Detox test APK..."
	npm run detox:build

detox-test:
	@echo "Running E2E tests..."
	npm run detox:test

deploy:
	@echo "Running complete deployment pipeline..."
	./deploy.sh

.DEFAULT_GOAL := help
