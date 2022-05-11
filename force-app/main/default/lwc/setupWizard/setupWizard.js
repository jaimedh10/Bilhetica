import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import DISCOUNT_OBJECT from "@salesforce/schema/Discount__c";
import CATEGORY_OBJECT from "@salesforce/schema/Category__c";

export default class SetupWizard extends LightningElement {
  discountObject = DISCOUNT_OBJECT;
  categoryObject = CATEGORY_OBJECT;
  showVenueForm = false;
  showDiscountForm = false;
  showSetupForm = true;
  showCategoriesForm = false;
  



  handleVenueForm() {
    this.showVenueForm = true;
    this.showDiscountForm = false;
    this.showSetupForm = false;
    this.showCategoriesForm = false;
  }

  handleDiscountForm() {
    this.showDiscountForm = true;
    this.showVenueForm = false;
    this.showSetupForm = false;
    this.showCategoriesForm = false;
  }

  handleCategoriesForm() {
    this.showCategoriesForm = true;
    this.showVenueForm = false;
    this.showDiscountForm = false;
    this.showSetupForm = false;
  }

  handleDiscountSuccess() {
    this.dispatchToast(
      "Success!",
      "The Discount has been successfully saved.",
      "success"
    );
    this.showDiscountForm = false;
    this.showSetupForm = true;
    //this.venueId = event.detail.id;
  }

  handleCategorySuccess() {
    this.dispatchToast(
      "Success!",
      "The Category has been successfully saved",
      "success"
    );
    this.showCategoriesForm = false;
    this.showSetupForm = true;
  }

  hideVenueForm() {
    this.showVenueForm = false;
    this.showSetupForm = true;
  }

  hideDiscountForm() {
    this.showDiscountForm = false;
    this.showSetupForm = true;
  }

  hideCategoriesForm() {
    this.showCategoriesForm = false;
    this.showSetupForm = true;
  }

  dispatchToast(title, message, variant) {
    this.hideLoading();
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }

  hideLoading() {
    this.isLoading = false;
  }

  showLoading() {
    this.isLoading = true;
  }
}
