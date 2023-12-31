import { deepEqual } from "fast-equals";
import RouteParser from "route-parser";
import { h, render } from "preact";
import "event-propagation-path";

class DecodingError extends Error {}

// Comparison function for route variables later on.
const equals = (a, b) => {
  if (a instanceof Object) {
    return b instanceof Object && deepEqual(a, b);
  } else {
    return !(b instanceof Object) && a === b;
  }
};

// `queueMicrotask` polyfill.
const queueTask = (callback) => {
  if (typeof window.queueMicrotask !== "function") {
    Promise.resolve()
      .then(callback)
      .catch((e) =>
        setTimeout(() => {
          throw e;
        }),
      );
  } else {
    window.queueMicrotask(callback);
  }
};

// Returns the route information by parsing the route.
const getRouteInfo = (url, routes) => {
  for (let route of routes) {
    if (route.path === "*") {
      return { route: route, vars: false };
    } else {
      let vars = new RouteParser(route.path).match(url);
      if (vars) {
        return { route: route, vars: vars };
      }
    }
  }
  return null;
};

// This is the root element, it intercepts click so navigation just works as
// expected without having to use custom elements for it.
const Root = (props) => {
  const handleClick = (event) => {
    // If someone prevented default we honor that.
    if (event.defaultPrevented) {
      return;
    }

    // If the control is pressed it means that the user wants
    // to open it a new tab so we honor that.
    if (event.ctrlKey) {
      return;
    }

    for (let element of event.propagationPath()) {
      if (element.tagName === "A") {
        // If the target is not empty then it's probably _blank or
        // an other window or frame so we skip.
        if (element.target.trim() !== "") {
          return;
        }

        if (element.origin === window.location.origin) {
          const fullPath = element.pathname + element.search + element.hash;
          const routeInfo = getRouteInfo(fullPath, props.routes);

          if (routeInfo) {
            event.preventDefault();
            navigate(
              fullPath,
              /* dispatch */ true,
              /* triggerJump */ true,
              routeInfo,
            );
            return;
          }
        }
      }
    }
  };

  const components = [];

  for (let key in props.globals) {
    components.push(h(props.globals[key], { key: key }));
  }

  return h("div", { onClick: handleClick }, [...components, ...props.children]);
};

class Program {
  constructor(ok, routes) {
    this.root = document.createElement("div");
    this.routeInfo = null;
    this.routes = routes;
    this.ok = ok;

    document.body.appendChild(this.root);

    window.addEventListener("popstate", (event) => {
      this.handlePopState(event);
    });
  }

  // Handles resolving the page position after a navigation event.
  resolvePagePosition(triggerJump) {
    // Queue a microTask, this will run after Preact does a render.
    queueTask(() => {
      // On the next frame, the DOM should be updated already.
      requestAnimationFrame(() => {
        const hash = window.location.hash;

        if (hash) {
          let elem = null;
          try {
            elem =
              this.root.querySelector(hash) || // ID
              this.root.querySelector(`a[name="${hash.slice(1)}"]`); // Anchor
          } finally {
          }

          if (elem) {
            if (triggerJump) {
              elem.scrollIntoView();
            }
          } else {
            console.warn(
              `MINT: ${hash} matches no element with an id and no link with a name`,
            );
          }
        } else if (triggerJump) {
          window.scrollTo(0, 0);
        }
      });
    });
  }

  // Handles navigation events.
  handlePopState(event) {
    const url =
      window.location.pathname + window.location.search + window.location.hash;

    const routeInfo = event?.routeInfo || getRouteInfo(url, this.routes);

    if (routeInfo) {
      if (
        this.routeInfo === null ||
        routeInfo.route.path !== this.routeInfo.route.path ||
        !equals(routeInfo.vars, this.routeInfo.vars)
      ) {
        this.runRouteHandler(routeInfo);
      }

      this.resolvePagePosition(!!event?.triggerJump);
    }

    this.routeInfo = routeInfo;
  }

  // Helper function for above.
  runRouteHandler(routeInfo) {
    const { route } = routeInfo;

    if (route.path === "*") {
      route.handler();
    } else {
      const { vars } = routeInfo;
      try {
        let args = route.mapping.map((name, index) => {
          const value = vars[name];
          const result = route.decoders[index](value);

          if (result instanceof this.ok) {
            return result._0;
          } else {
            throw new DecodingError();
          }
        });

        route.handler.apply(null, args);
      } catch (error) {
        if (error.constructor !== DecodingError) {
          throw error;
        }
      }
    }
  }

  // Renders the program and runs current route handlers.
  render(main, globals) {
    if (typeof main !== "undefined") {
      render(
        h(Root, { routes: this.routes, globals: globals }, [
          h(main, { key: "$MAIN" }),
        ]),
        this.root,
      );

      this.handlePopState();
    }
  }
}

// Function to navigate to a different url.
export const navigate = (
  url,
  dispatch = true,
  triggerJump = true,
  routeInfo = null,
) => {
  let pathname = window.location.pathname;
  let search = window.location.search;
  let hash = window.location.hash;

  let fullPath = pathname + search + hash;

  if (fullPath !== url) {
    if (dispatch) {
      window.history.pushState({}, "", url);
    } else {
      window.history.replaceState({}, "", url);
    }
  }

  if (dispatch) {
    let event = new PopStateEvent("popstate");
    event.triggerJump = triggerJump;
    event.routeInfo = routeInfo;
    dispatchEvent(event);
  }
};

// Creates a program.
export const program = (main, globals, ok, routes = []) => {
  new Program(ok, routes).render(main, globals);
};
