/* eslint-disable @typescript-eslint/no-var-requires */
const webpack = require("webpack");
const path = require("path");
const HtmlWebPackPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

const miniCssExtractPlugin = new MiniCssExtractPlugin({
	filename: "css/[name].css",
	chunkFilename: "css/[id].css"
});

module.exports = (env, argv) => {
	const isProd = (argv.mode === "production");
	const public = path.resolve(__dirname, "../docs");
	const htmlPlugin = new HtmlWebPackPlugin({
		template: "./src/index.html",
		filename: path.resolve(public, "index.html")
	});
	const config = {
		entry: {
			bundle: "./src/scripts/main.tsx"
		},
		output: {
			path: public,
			filename: "js/[name].js"
		},
		resolve: {
			extensions: [".tsx", ".ts", ".js"]
		},
		module: {
			rules: [
				{
					test: /\.tsx?$/,
					include: path.resolve(__dirname, "src", "scripts"),
					use: "ts-loader"
				},
				{
					test: /\.css$/,
					use: ["style-loader", "css-loader"]
				},
				{
					test: /\.scss$/,
					use: [
						{
							loader: MiniCssExtractPlugin.loader
						},
						{
							loader: "css-loader",
							options: {
								sourceMap: !isProd
							}
						},
						{
							loader: "sass-loader",
							options: {
								sourceMap: !isProd,
								outFile: `../docs/css/main.css`,
								minimize: true
							}
						}
					]
				},
				{
					test: /\.(png|svg|jpg|gif)$/,
					use: {
						loader: "file-loader",
						options: {
							name: "imgs/[name].[ext]"
						}
					}
				},
				{
					test: /\.lua$/,
					use: {
						loader: "file-loader",
						options: {
							name: "lua/[name].[ext]"
						}
					}
				}
			]
		},
		plugins: [
			htmlPlugin,
			miniCssExtractPlugin,
			new webpack.DefinePlugin({

			})
		]
	};
	if (!isProd) {
		config.devtool = "inline-source-map";
	}
	return config;
};
