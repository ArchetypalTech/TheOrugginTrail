import { LitElement, html, css, PropertyValues } from "lit";
import { createWalletClient } from 'viem'
import { getNetworkConfig } from "../mud/getNetworkConfig";

class LitWallet extends LitElement {
  declare inputValue: string;
  declare networkConfig: any;

  static get properties() {
    return {
      inputValue: { type: String },
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
    this.inputValue = '> '; // Initialize your property
  }

  static styles = css`
      :host {
          display: block;
          margin: 0;
      }

      input {
          color: forestgreen;
          background: black;
          outline: none;
          border: black;
          font-family: 'Courier', sans-serif;
          font-size: 16px;
          box-sizing: border-box;
          margin-bottom: 8px;
          margin-left: 4px;
      }

      .wallet {
          width: 40%;
          height: 100px;
          color: forestgreen;
          background: black;
          border: 1px solid yellowgreen;
          border-radius: 4px;
          font-family: 'Courier', sans-serif;
          font-size: 16px;
          margin: 4px;
      }
  `;

  render() {
    return html`
      <div class="wallet">
        <input type="text" .value="${this.inputValue}"
      </div>
    `;
  }
}
customElements.define('l-wallet', LitWallet);
