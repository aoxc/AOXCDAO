import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

/**
 * @file eslint.config.mjs
 * @description Apex-Grade Static Analysis Configuration for the AOXC Type System.
 * This configuration enforces strict architectural discipline and type safety
 * across the 55-file Sovereign Fleet DNA layer.
 */

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ['types/**/*.ts'],
    languageOptions: {
      parserOptions: {
        project: './tsconfig.json',
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      // PROHIBITION OF AMBIGUITY: Ensures zero-tolerance for untyped variables
      "@typescript-eslint/no-explicit-any": "error",
      
      // RESOURCE OPTIMIZATION: Identifies dormant variables while allowing underscore-prefixed parameters
      "@typescript-eslint/no-unused-vars": ["warn", { "argsIgnorePattern": "^_" }],
      
      // IMMUTABILITY ENFORCEMENT: Enforces persistent state logic across fleet directives
      "prefer-const": "error",
      
      // HIERARCHICAL STANDARDIZATION: Mandatory 'I' prefix for Interface definitions
      "@typescript-eslint/naming-convention": [
        "error",
        { 
          "selector": "interface", 
          "format": ["PascalCase"], 
          "prefix": ["I"] 
        }
      ]
    },
  },
  {
    // ISOLATION BARRIERS: Prevents the analyzer from breaching build artifacts and external dependencies
    ignores: ["node_modules/", "out/", "cache/"]
  }
);
