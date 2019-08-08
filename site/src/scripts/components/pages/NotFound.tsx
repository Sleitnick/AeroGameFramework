import * as React from "react";

export default class NotFound extends React.Component {

	public constructor(props) {
		super(props);
	}

	public render(): JSX.Element {
		return (
			<div>
				<h1>Not Found</h1>
				<p>Sorry, the page you requested was not found.</p>
			</div>
		);
	}

}