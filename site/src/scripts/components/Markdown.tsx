import * as React from "react";
import * as marked from "marked";
import * as Prism from "prismjs";

marked.setOptions({
	highlight: function(code) {
		return Prism.highlight(code, Prism.languages.lua, "lua");
	}
});

export default class Markdown extends React.Component {

	constructor(props) {
		super(props);
		this.removeLeadingTabs = this.removeLeadingTabs.bind(this);
	}

	public render() {
		const children = this.removeLeadingTabs(this.props.children.toString());
		return (
			<div
				dangerouslySetInnerHTML={{__html: marked(children)}}
				className="markdown"
			/>
		);
	}

	private removeLeadingTabs(str: string): string {
		const lines = str.split("\n");
		let minTabs = Number.MAX_SAFE_INTEGER;
		for (const line of lines) {
			const tabs = line.match(/^\t+/);
			if (tabs && tabs[0].length < minTabs) {
				minTabs = tabs[0].length;
			}
		}
		for (let i = 0; i < lines.length; i++) {
			const line = lines[i];
			if (line.match(/^\t+/)) {
				lines[i] = line.substring(minTabs + 1);
			}
		}
		return lines.join("\n");
	}

}