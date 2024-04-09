import { LitElement, html, css } from 'lit';

class LitWallet extends LitElement {
  declare inputValue: string;

  static get properties() {
    return {
      inputValue: { type: String },
    };
  }

  constructor() {
    super();
    this.inputValue = '> '; // Initialize your property
    // @ts-ignore
    this.history = [
      "Archetypal Tech welcomes you to DEATH"
      , "well possibly..."
      , "\n"
      , "The O'Ruggin Trail, no:23"
      , "from the good folk at"
      , "Best Archetypal System Terminals And Retrograde Devices"
      , "\n"
    ];
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
          color: forestgreen;
          background: black;
          border: 1px solid chartreuse;
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
        <input type="text" .value="${this.inputValue}"
      </div>
    `;
  }
}
customElements.define('l-wallet', LitWallet);
