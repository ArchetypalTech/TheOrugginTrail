import { LitElement, html, css } from 'lit';
import walletOutputStyle from "../../styles/wallet/walletOutputStyle";

class DynamicContentComponent extends LitElement {

  declare content : string;
  declare history : Array<string>;

  // @ts-ignore
  static styles = css([walletOutputStyle]);

  static get properties() {
    return {
      content: { type: String }
    };
  }

  constructor() {
    super();
    this.content = ""; // Initialize
    this.history = [];
  }

}