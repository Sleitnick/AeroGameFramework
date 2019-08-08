import * as React from "react";
import * as marked from "marked";
import * as Prism from "prismjs";
import * as PropTypes from 'prop-types';

marked.setOptions({
	highlight: function(code): string {
		return Prism.highlight(code, Prism.languages.lua, "lua");
	}
});

class Markdown extends React.Component {

	public static propTypes = {
		children: PropTypes.node.isRequired
	};

	public constructor(props) {
		super(props);
		this.removeLeadingTabs = this.removeLeadingTabs.bind(this);
	}

	public render(): JSX.Element {
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

export default Markdown;