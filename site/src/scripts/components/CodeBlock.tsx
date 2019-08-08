import * as React from "react";
import * as Prism from "prismjs";

interface CodeBlockProps {
	src: string;
}

export default class CodeBlock extends React.Component<CodeBlockProps> {

	private readonly codeRef: React.RefObject<HTMLDivElement>;

	public constructor(props: CodeBlockProps) {
		super(props);
		this.highlight = this.highlight.bind(this);
		this.codeRef = React.createRef();
	}

	public componentDidMount(): void {
		this.highlight();
	}

	public componentDidUpdate(): void {
		this.highlight();
	}

	public render(): JSX.Element {
		return (
			<div ref={this.codeRef}>
				<pre className="line-numbers" data-src={this.props.src}/>
			</div>
		);
	}

	private highlight(): void {
		Prism.fileHighlight(this.codeRef.current);
	}

}