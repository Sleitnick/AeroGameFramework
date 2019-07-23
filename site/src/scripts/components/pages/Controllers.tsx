import * as React from "react";
import CodeBlock from "../CodeBlock";
import Markdown from "../Markdown";

import "../../lua/controller_01.lua";

export default class Controllers extends React.Component {

	constructor(props) {
		super(props);
	}

	public render() {
		return (
			<div>

				<Markdown>
				{`
					# Controllers

					A service is a singleton initiated at runtime on the server. Services should serve specific purposes. For instance,
					the provided DataService allows simplified data management. You might also create a WeaponService, which might
					be used for holding and figuring out weapon information for the players.

					A controller is a singleton initiated at runtime on the client. Controllers should serve a specific purpose. For
					instance, the provided Fade controller allows for control of simple screen fading. Controllers often interact
					with server-side services as well. Another example of a controller could be a Camera controller, which has the
					task of specifically controlling the player's camera.

					------------------

					### API

					A controller in its simplest form looks like this:
				`}
				</Markdown>
				<CodeBlock src="lua/controller_01.lua"/>

			</div>
		);
	}

}