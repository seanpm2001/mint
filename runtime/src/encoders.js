import { identity } from "./utilities";

// Encodes `Time`
export const encodeTime = (value) => value.toISOString();

// Encodes `Array(item)`
export const encodeArray = (encoder) => (value) => {
  return value.map((item) => {
    return encoder ? encoder(item) : item;
  });
};

// Encodes `Map(String, value)` as a JS object.
export const encodeMap = (encoder) => (value) => {
  const result = {};

  for (let item of value) {
    result[item[0]] = encoder ? encoder(item[1]) : item[1];
  }

  return result;
};

// Encodes `Maybe`. `Nothing` becomes `null`.
export const encodeMaybe = (encoder, just) => (value) => {
  if (value instanceof just) {
    return encoder(value._0);
  } else {
    return null;
  }
};

// Encodes `Tuple(...)`
export const encodeTuple = (encoders) => (value) => {
  return value.map((item, index) => {
    const encoder = encoders[index];
    return encoder ? encoder(item) : item;
  });
};

// Encode a record with the encoders.
export const encoder = (encoders) => (value) => {
  const result = {};

  for (let key in encoders) {
    let encoder = encoders[key];
    let field = key;

    if (Array.isArray(encoder)) {
      encoder = encoders[key][0];
      field = encoders[key][1];
    }

    result[field] = (encoder || identity)(value[key]);
  }

  return result;
};
