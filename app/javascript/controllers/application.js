import { Application } from "@hotwired/stimulus"
import StarsController from "./stars_controller";

const application = Application.start()

application.register("stars", StarsController);

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application
export { application }
