import React, { Component } from "react";
import ItemManager from "./contracts/ItemManager.json";
import ItemContract from "./contracts/Item.json"
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  state = { loaded: false, cost:0, itemName: "example_1" };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      this.web3 = await getWeb3();
      console.log(this.web3)
      // Use web3 to get the user's accounts.
      this.accounts = await this.web3.eth.getAccounts();

      // Get the contract instance.
      this.networkId = await this.web3.eth.net.getId();
      this.itemManager = new this.web3.eth.Contract(
        ItemManager.abi,
        ItemManager.networks[this.networkId] && ItemManager.networks[this.networkId].address,
      );

      this.item = new this.web3.eth.Contract(
        ItemContract.abi,
        ItemContract.networks[this.networkId] && ItemContract.networks[this.networkId].address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.listenToPaymentEvent();
      this.setState({ loaded: true });
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  handleInputChange = (event) => {
    const target = event.target;
    const value = target.type === "checkbox" ? target.check : target.value;
    const name = target.name;
    this.setState({
      [name]: value
    })
  }

  listenToPaymentEvent = () => {
    let self = this;
    this.itemManager.events.SupplyChainStep().on('data', async function(evt) {
      console.log(evt);
      let itemObj = self.itemManager.methods.items(evt.returnValues._itemIndex).call();
      console.log(itemObj);
      alert("Item " + itemObj._identifier + " was paid, deliver it now!");
    })
  }

  handleSubmit = async() => {
    const {cost, itemName} = this.state;
    let result = await this.itemManager.methods.createItem(itemName, cost).send({from: this.accounts[0]});
    console.log(result);
    alert("Sent " + cost + " to " + result.events.SupplyChainStep.returnValues._itemAddress);
  }

  render() {
    if (!this.state.loaded) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Event trigger / SupplyChain example</h1>
        <h2>Items</h2>
        <h2>Add Items</h2>
        <p>Cost in Wei : <input type="text" name="cost" value={this.state.cost} onChange={this.handleInputChange}/></p>
        <p>Item identifier : <input type="text" name="itemName" value={this.state.itemName} onChange={this.handleInputChange}/></p>
        <button type="button" onClick={this.handleSubmit}>Add Item</button>
      </div>
    );
  }
}

export default App;
