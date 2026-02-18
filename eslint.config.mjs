import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

/**
 * @file eslint.config.mjs
 * @description Apex-Grade Static Analysis Configuration for the AOXC Type System.
 * Aligned with the uppercase TYPES authority and strict academic standards.
 */

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    // ALIGNMENT: Pointing to the uppercase sovereign directory
    files: ['TYPES/**/*.ts', 'AOXCORE/**/*.ts', 'SCRIPTS/**/*.ts'],
    languageOptions: {
      parserOptions: {
        project: './tsconfig.json',
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      // PROHIBITION OF AMBIGUITY: Zero-tolerance for untyped variables
      "@typescript-eslint/no-explicit-any": "error",
      
      // RESOURCE OPTIMIZATION: In our fleet, unused variables are considered logic leaks.
      // Upgraded to "error" for CertiK-level cleanliness.
      "@typescript-eslint/no-unused-vars": ["error", { 
        "argsIgnorePattern": "^_",
        "varsIgnorePattern": "^_" 
      }],
      
      // IMMUTABILITY ENFORCEMENT: Enforces persistent state logic
      "prefer-const": "error",
      
      // HIERARCHICAL STANDARDIZATION: Mandatory 'I' prefix for Interface definitions
      "@typescript-eslint/naming-convention": [
        "error",
        { 
          "selector": "interface", 
          "format": ["PascalCase"], 
          "prefix": ["I"] 
        }
      ],

      // ACADEMIC DISCIPLINE: Enforce semicolons and single quotes for consistency
      "semi": ["error", "always"],
      "quotes": ["error", "single"]
    },
  },
  {
    // ISOLATION BARRIERS: Enhanced to exclude all build and cache artifacts
    ignores: [
      "node_modules/", 
      "out/", 
      "cache/", 
      "dist/", 
      ".tsbuildinfo",
      "REPORTS/"
    ]
  }
);
