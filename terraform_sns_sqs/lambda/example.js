"use strict";
import _ from "lodash";
import moment from "moment";

export const hello = async (event, context, callback) => {
  const curried = _.curry(calculateDate);
  callback(null, curried(moment().format())(event));
};

const calculateDate = (datetime, days) => {
  return moment()
    .add(days, "days")
    .format("Do MMMM YYYY, h:mm:ss a");
};