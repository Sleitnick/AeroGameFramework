module.exports = {
	"parser": "@typescript-eslint/parser",
	"plugins": ["@typescript-eslint"],
	"env": {
		"es6": true,
		"commonjs": true,
		"browser": true
	},
	"extends": [
		"plugin:@typescript-eslint/recommended"
	],
	"parserOptions": {
		"project": "./site/tsconfig.json",
		"ecmaFeatures": {
			"jsx": true
		}
	},
	"rules": {
		"@typescript-eslint/indent": "off"
	}
};