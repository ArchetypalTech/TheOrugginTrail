import { LitElement, html, css, PropertyValues } from "lit";
import { createWalletClient } from 'viem'
import { getNetworkConfig } from "../../mud/getNetworkConfig";
import { cssString } from "../../styles/wallet/walletStyle";

class LitWallet extends LitElement {
  declare inputValue: string;
  declare networkConfig: any;
  declare history: Array<string>;

  static get properties() {
    return {
      inputValue: { type: String },
      history: {type: Array}
    };
  }

  protected async firstUpdated(_changedProperties: PropertyValues) {
    super.firstUpdated(_changedProperties);
    console.log("first updated....")
    this.networkConfig = await getNetworkConfig();
    console.log("Fetched config");
  }

  constructor() {
    super();
    this.inputValue = '> type "connect" to add a wallet'; // Initialize
    // @ts-ignore
    this.history = [
      "Archetypal Tech Wallet Facility no:23"
    ];
  }

  // @ts-ignore
  static styles = css([cssString]);

  render() {
    return html`
      <div class="wallet">
        ${this.history.map(line => html`<div class="output">${line}</div>`)}
        <input type="text" .value="${this.inputValue}"
               @keydown="${this.handleEnter}"
               @input=${this.handleInput}
               @focus=${this.handleFocus}>
      </div>
    `;
  }

  private stripCommandString(s: string) {
    let seq = "> ";
    return s.replace(seq, "");
  }

  private handleFocus() {
    this.inputValue = '> ';
  }

  updated() {
    const container = this.shadowRoot.querySelector(".wallet");
    if (container) {
      container.scrollTop = container.scrollHeight;
    }
  }

  private propmtConnect() {
    console.log('connecting');
    let provider = window.ethereum;
    if (provider) {
      if (provider.isMetaMask) {
        this.history = [...this.history, "connect", "found metamask"];
        this.inputValue = '?connect y/n > ';
      }else {
        this.inputValue = '> ';
      }
    }
  }

  private startConnection() {
    console.log('foobar');
    this.inputValue = '> ';
    this.history = [...this.history, 'connecting...'];
  }

  private handleCommand(cmd: string) {
    switch (cmd) {
      case "connect":
        this.propmtConnect();
        break;
      case "?connect y/n y":
        this.startConnection();
        break;
      default:
        this.history = [...this.history, cmd, `bad command: try "connect"`];
    }
  }

  private handleEnter(e: KeyboardEvent) {
    if (e.key === 'Enter') {
      const commandStr = this.stripCommandString(this.inputValue);
      this.handleCommand(commandStr);
      // this.dispatchEvent(new CustomEvent('command-update', {
      //   detail: { value: commandStr },
      //   bubbles: true, // Allows the event to bubble up through the DOM
      //   composed: true // Allows the event to cross the shadow DOM boundary
      // }));
    }
  }
  private handleInput(e: Event) {
    const input = e.target as HTMLInputElement;
    const elem = e.target as EventTarget;
    let newVal = input.value;
    // @ts-ignore
    if (this.inputValue === newVal && this.inputValue !== (elem as HTMLInputElement ).value) {
      (elem as HTMLInputElement).value = this.inputValue;
    } else {
      this.inputValue = newVal;
    }
  }
}
customElements.define('l-wallet', LitWallet);