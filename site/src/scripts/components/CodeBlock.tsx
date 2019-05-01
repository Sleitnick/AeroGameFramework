import * as React from "react";
import * as Prism from "prismjs";

interface CodeBlockProps {
	src: string;
}

export default class CodeBlock extends React.Component<CodeBlockProps> {

	private readonly codeRef: React.RefObject<HTMLDivElement>;

	constructor(props: CodeBlockProps) {
		super(props);
		this.highlight = this.highlight.bind(this);
		this.codeRef = React.createRef();
	}

	public componentDidMount() {
		this.highlight();
	}

	public componentDidUpdate() {
		this.highlight();
	}

	public render() {
		return (
			<div ref={this.codeRef}>
				<pre className="line-numbers" data-src={this.props.src}/>
			</div>
		);
	}

	private highlight() {
		Prism.fileHighlight(this.codeRef.current);
	}

}