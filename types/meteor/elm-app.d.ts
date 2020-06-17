declare module "meteor/elm-app" {
  export const init: (
    configuration: import("/packages/elm-app/app").Configuration
  ) => import("/packages/elm-app/app").Ports;
}
