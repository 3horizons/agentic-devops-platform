import { Component } from "@angular/core";

@Component({
  selector: "app-root",
  template: `<h1>${{values.appName}}</h1><p>${{values.description}}</p>`,
  standalone: true,
})
export class AppComponent {
  title = "${{values.appName}}";
}
