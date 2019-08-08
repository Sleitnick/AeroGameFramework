module.exports = {
	"parser": "@typescript-eslint/parser",
	"plugins": ["@typescript-eslint", "react"],
	"env": {
		"es6": true,
		"commonjs": true,
		"browser": true
	},
	"extends": [
		"eslint:recommended",
		"plugin:react/recommended",
		"plugin:@typescript-eslint/recommended"
	],
	"parserOptions": {
		"project": "./tsconfig.json",
		"ecmaFeatures": {
			"jsx": true
		}
	},
	"settings": {
		"react": {
			"pragma": "React",
			"version": "detect"
		}
	},
	"rules": {
		"@typescript-eslint/indent": "off"
	}
};