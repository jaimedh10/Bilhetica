import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import DISCOUNT_OBJECT from "@salesforce/schema/Discount__c";
import CATEGORY_OBJECT from "@salesforce/schema/Category__c";

export default class SetupWizard extends LightningElement {
  discountObject = DISCOUNT_OBJECT;
  categoryObject = CATEGORY_OBJECT;
  showShortVenueForm = false;
  showDiscountForm = false;
  showSetupForm = true;
  showCategoriesForm = false;
  showShortDiscountForm = false;
  showShortCategoriesForm = false;
  showButtons = false;

  categories = [];
  discounts = [];
  
  venueProgressRing = 0;
  categoryProgressRing = 0;
  discountProgressRing = 0;




  handleShortVenueForm() {
    this.showShortVenueForm = true;
    this.showDiscountForm = false;
    this.showSetupForm = false;
    this.showCategoriesForm = false;
    this.showButtons = true;
  }

  handleDiscountForm() {
    this.showDiscountForm = true;
    this.showShortVenueForm = false;
    this.showSetupForm = false;
    this.showCategoriesForm = false;
    this.showShortDiscountForm = false;
  }

  handleShortDiscountForm() {
    this.showShortDiscountForm = true;
    this.showShortVenueForm = false;
    this.showSetupForm = false;
    this.showCategoriesForm = false;
  }

  handleCategoriesForm() {
    this.showCategoriesForm = true;
    this.showShortCategoriesForm = false;
    this.showSetupForm = false;
  }

  handleShortCategoriesForm() {
    this.showShortCategoriesForm = true;
    this.showShortVenueForm = false;
    this.showSetupForm = false;
    this.showCategoriesForm = false;
  }

  handleDiscountSuccess(event) {
    // insere o novo desconto na lista
    this.discountId = event.detail.id;
    this.discounts.push(this.discountId);
    console.table(this.discounts);

    this.dispatchToast(
      "Success!",
      "The Discount has been successfully saved.",
      "success"
    );
    this.hideDiscountForm();
    this.discountProgressRing = 100;
  }

  handleCategorySuccess(event) {
    this.categoryId = event.detail.id;
    this.categories.push(this.categoryId);
    console.table(this.categories);
    this.dispatchToast(
      "Success!",
      "The Category has been successfully saved",
      "success"
    );
    this.hideCategoryForm();
    this.categoryProgressRing = 100;
  }

  hideShortVenueForm() {
    this.showShortVenueForm = false;
    this.showSetupForm = true;
    this.venueProgressRing = 100;
  }

  hideDiscountForm() {
    this.showDiscountForm = false;
    this.showShortDiscountForm = true;
  }

  hideShortDiscountForm() {
    this.showShortDiscountForm = false;
    this.showDiscountForm = false;
    this.showSetupForm = true;
  }

  hideCategoryForm() {
    this.showCategoriesForm = false;
    this.showShortCategoriesForm = true;
  }

  hideShortCategoriesForm() {
    this.showShortCategoriesForm = false;
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
