import { MetaMaskSDK } from "@metamask/sdk";

const MMSDK = new MetaMaskSDK({
  dappMetadata: {
    name: "JavaScript example dapp",
    url: window.location.href,
  },
  // Other options
});

// You can also access via window.ethereum
// const ethereum = MMSDK.getProvider();
// Create a new <div> element
const buttonDiv = document.createElement("div");

// Assign an ID to the <div>
buttonDiv.id = "metaWallet";

// Optionally, set some content for the <div>
buttonDiv.textContent = "Interact with MetaMask.";

const performAsyncOperation = async () => {
  console.log("Starting async operation...");
  if(window.ethereum) {
    await window.ethereum.request({ method: 'eth_requestAccounts' });
    console.log('fetched?');
  }
  console.log("Async operation completed.");
};

const asyncButtonHandler = async () => {
  try {
    await performAsyncOperation();
    console.log("Operation was successful.");
  } catch (error) {
    console.error("An error occurred during the operation.", error);
  }
};

// Create a new button element
const button = document.createElement('button');

button.textContent = "Connect";

button.addEventListener("click", asyncButtonHandler);

buttonDiv.appendChild(button);

document.body.appendChild(buttonDiv);