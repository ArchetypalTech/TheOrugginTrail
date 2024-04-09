import { LitElement, html, css, PropertyValues } from "lit";
import { createWalletClient } from 'viem'
import { getNetworkConfig } from "../mud/getNetworkConfig";

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
    this.inputValue = '> Please enter an address...'; // Initialize your property
    // @ts-ignore
    this.history = [
      "Archetypal Tech Wallet Facility no:23"
    ];
  }

  static styles = css`
      :host {
          display: block;
          margin: 0;
      }

      input {
          color: greenyellow;
          width: 90%;
          background: black;
          outline: none;
          border: black;
          font-family: 'Courier', sans-serif;
          font-size: 16px;
          box-sizing: border-box;
          margin-bottom: 8px;
          margin-left: 4px;
          margin-right: 4px;
      }

      .wallet {
          width: 40%;
          height: 100px;
          overflow-y: auto;
          color: greenyellow;
          background: black;
          border: 1px solid yellow;
          border-radius: 4px;
          font-family: 'Courier', sans-serif;
          font-size: 16px;
          margin: 4px;
      }
      .output {
           width: 80%;
           margin-left: auto;
           margin-right: auto;
           margin-top: 8px;
           margin-bottom: 8px;
           text-align: left;
           white-space: pre-wrap;
       }
  `;

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

  private handleEnter(e: KeyboardEvent) {
    if (e.key === 'Enter') {
      const commandStr = this.stripCommandString(this.inputValue);
      // this.dispatchEvent(new CustomEvent('command-update', {
      //   detail: { value: commandStr },
      //   bubbles: true, // Allows the event to bubble up through the DOM
      //   composed: true // Allows the event to cross the shadow DOM boundary
      // }));
      this.history = [...this.history, commandStr];
      this.inputValue = '> ';
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