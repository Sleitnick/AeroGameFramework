import * as React from "react";
import CodeBlock from "../CodeBlock";
import Markdown from "../Markdown";

import "../../lua/service_01.lua";
import "../../lua/service_02.lua";
import "../../lua/service_03.lua";
import "../../lua/service_04.lua";
import "../../lua/service_05.lua";
import "../../lua/service_06.lua";
import "../../lua/service_07.lua";
import "../../lua/service_08.lua";
import "../../lua/service_09.lua";
import "../../lua/service_10.lua";
import "../../lua/service_11.lua";

export default class Services extends React.Component {

	constructor(props) {
		super(props);
	}

	public render() {
		return (
			<div>

				<Markdown>
				{`
					# Services

					A service is a singleton initiated at runtime on the server. Services should serve specific purposes. For instance,
					the provided DataService allows simplified data management. You might also create a WeaponService, which might
					be used for holding and figuring out weapon information for the players.

					------------------

					### API

					A service in its simplest form looks like this:
				`}
				</Markdown>
				<CodeBlock src="lua/service_01.lua"/>

				<br/>
				<h5>Injected Properties:</h5>
				<table className="table table-striped">
					<thead>
						<tr>
							<th>Property</th>
							<th>Description</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><code><i>service</i>.Services</code></td>
							<td>Table of all other services, referenced by the name of the ModuleScript</td>
						</tr>
						<tr>
							<td><code><i>service</i>.Modules</code></td>
							<td>Table of all modules, referenced by the name of the ModuleScript</td>
						</tr>
						<tr>
							<td><code><i>service</i>.Shared</code></td>
							<td>Table of all shared modules, referenced by the name of the ModuleScript</td>
						</tr>
						<tr>
							<td><code><i>service</i>.Client.Server</code></td>
							<td>Reference back to the service, so client-facing methods can invoke server-facing methods</td>
						</tr>
					</tbody>
				</table>

				<br/>
				<h5>Injected Methods:</h5>
				<table className="table table-striped">
					<thead>
						<tr>
							<th>Return</th>
							<th>Method</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>void</td>
							<td><code><i>service</i>:WrapModule(Table tbl)</code></td>
						</tr>
						<tr>
							<td>void</td>
							<td><code><i>service</i>:RegisterEvent(String eventName)</code></td>
						</tr>
						<tr>
							<td>void</td>
							<td><code><i>service</i>:RegisterClientEvent(String eventName)</code></td>
						</tr>
						<tr>
							<td>void</td>
							<td><code><i>service</i>:FireEvent(String eventName, ...)</code></td>
						</tr>
						<tr>
							<td>void</td>
							<td><code><i>service</i>:FireClientEvent(String eventName, Player player, ...)</code></td>
						</tr>
						<tr>
							<td>void</td>
							<td><code><i>service</i>:FireAllClientsEvent(String eventName, ...)</code></td>
						</tr>
						<tr>
							<td>Connection</td>
							<td><code><i>service</i>:ConnectEvent(String eventName, Function handler)</code></td>
						</tr>
						<tr>
							<td>Connection</td>
							<td><code><i>service</i>:ConnectClientEvent(String eventName, Function handler)</code></td>
						</tr>
					</tbody>
				</table>

				<Markdown>
				{`
					---------------------

					### \`service:Init()\`
					
					The \`Init\` method is called on each service in the framework in a synchronous and linear progression. In other
					words, each service's \`Init\` method is invoked one after the other. Each \`Init\` method must fully execute before
					moving onto the next. This is essentially the constructor for the service singleton.

					The method should be used to set up your service. For instance, you might want to create events or reference other services.

					The \`Init\` method should _not_ invoke any methods from other services yet, because it is not guaranteed that those
					services have had their \`Init\` methods invoked yet. It is safe to _reference_ other services, but not to invoke their methods.

					Use the \`Init\` method to register events and initialize any necessary components before the \`Start\` method is invoked.

					---------------------

					### \`service:Start()\`

					The \`Start\` method is called after all services have been initialized (i.e. their \`Init\` methods have been
					fully executed). Each \`Start\` method is executed on a _separate_ thread (asynchronously). From here, it is safe to reference
					and invoke other services in the framework

					---------------------

					### Custom Methods

					Adding your own methods to a service is very easy. Simply attach a function to the service table:
					
				`}
				</Markdown>
				<CodeBlock src="lua/service_02.lua"/>
				<Markdown>Other services can also invoke your custom method:</Markdown>
				<CodeBlock src="lua/service_03.lua"/>

				<Markdown>
				{`
					---------------------

					### Server Events

					You can create and listen to events using the \`RegisterEvent\`, \`ConnectEvent\`, and \`FireEvent\` methods.
					All events should _always_ be registered within the \`Init\` method. The \`ConnectEvent\` and \`FireEvent\`
					methods should _never_ be used within an \`Init\` method.
				`}
				</Markdown>
				<CodeBlock src="lua/service_04.lua"/>

				<Markdown>
				{`
					---------------------

					### WrapModule

					The \`WrapModule\` method can be used to transform a table into a framework-like module. In other words, it sets
					the table's metatable to the same metatable used by other framework modules, thus exposing the framework to the
					given table.
				`}
				</Markdown>
				<CodeBlock src="lua/service_05.lua"/>
				<Markdown>
				{`
					This can be useful if you are requiring other non-framework modules in which you want to expose the framework.

					---------------------

					### Client Table

					The \`Client\` table is used to expose methods and events to the client.

					##### Client Methods

					To expose a method to the client, write a function attached to the client table:
				`}
				</Markdown>
				<CodeBlock src="lua/service_06.lua"/>
				<Markdown>
				{`
					Note that the \`player\` argument must _always_ be the first argument for client methods. Any other arguments
					reflect what the client has sent.

					##### Client Events

					To expose an event to the client, use the \`RegisterClientEvent\` method in the \`Init\` method. Use
					\`FireClientEvent\` and \`FireAllClientsEvent\` to fire the event:
				`}
				</Markdown>
				<CodeBlock src="lua/service_07.lua"/>
				<br/>
				<Markdown>
				{`
					##### Reference Server Table

					When executing code with a client-exposed method, it is useful to be able to reference back to the main
					service table. Therefore, the \`Server\` property has been injected into the \`Client\` table:
				`}
				</Markdown>
				<CodeBlock src="lua/service_08.lua"/>

				<Markdown>
				{`
					---------------------

					## Other Examples

					##### Invoking another service:
				`}
				</Markdown>
				<CodeBlock src="lua/service_09.lua"/>
				<br/>
				<Markdown>##### Using a Module:</Markdown>
				<CodeBlock src="lua/service_10.lua"/>
				<br/>
				<Markdown>##### Using a Shared module:</Markdown>
				<CodeBlock src="lua/service_11.lua"/>

			</div>
		);
	}

}
