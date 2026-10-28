module.exports = {
  extends: ["html-validate:recommended"],
  rules: {
    // Coq ids legitimately contain ':' (binders) and '.' (qualified names),
    // same convention as coqdoc; valid per the HTML5 id spec.
    "valid-id": "off",

    // HB structures can share an id with their auto-generated "Exports"
    // definition. Known issue, same limitation as coqdoc, not fixed yet.
    "no-dup-id": "off",

    // Coq module paths are long and hierarchical; the 70-char SEO limit
    // doesn't apply here.
    "long-title": "off",

    // Left enabled: the one accepted exception (.tooltip-area in
    // bin/tooltip.ml) is suppressed locally via html-validate-disable-block.
  },
};
