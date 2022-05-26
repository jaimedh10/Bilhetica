import { LightningElement } from "lwc";
import { getBarcodeScanner } from "lightning/mobileCapabilities";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import checkQrCode from "@salesforce/apex/TicketCustomController.checkQrCode";

export default class QrCodeScanner extends LightningElement {
  myScanner;
  scanButtonDisabled = false;
  scannedBarcode = "";




  // When component is initialized, detect whether to enable Scan button
  connectedCallback() {
    this.myScanner = getBarcodeScanner();
    if (this.myScanner == null || !this.myScanner.isAvailable()) {
      this.scanButtonDisabled = true;
    }
  }

  handleBeginScanClick(event) {
    // Reset scannedBarcode to empty string before starting new scan
    this.scannedBarcode = "";

    if (this.myScanner != null && this.myScanner.isAvailable()) {
      const scanningOptions = {
        barcodeTypes: [this.myScanner.barcodeTypes.QR]
      };

      this.myScanner
        .beginCapture(scanningOptions)
        .then((result) => {
          console.log(result);
          this.scannedBarcode = decodeURIComponent(result.value);
          checkQrCode({ qrCodeUrl: this.scannedBarcode })
            .then((validation) => {
              console.log(validation);
              if (validation != null) {
                this.dispatchToast(
                  "Success!",
                  "The QRCode was successfully validated.",
                  "success"
                );
              }
            })
            .catch((error) => {
              this.error = error;
              console.log(error);
            });
        })
        .catch((error) => {
          console.error(error);
          // Handle unexpected errors here
        })
        .finally(() => {
          this.myScanner.endCapture();
        });
    } else {
      // BarcodeScanner is not available
      // Not running on hardware with a camera, or some other context issue
      console.log(event);
      this.dispatchToast(
        "Barcode Scanner Is Not Available",
        "Try again from the Salesforce app on a mobile device.",
        "error"
      );
    }
  }

  dispatchToast(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}
