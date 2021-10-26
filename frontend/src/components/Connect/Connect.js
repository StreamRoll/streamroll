import React from "react";
import css from "./Connect.css";
import connect from "../../images/Connect.png";

const Connect = (props) => {
  return (
    <div className="Connect">
      {props.userAddress == "" ? (
        <img
          src={connect}
          width="150"
          onClick={props.onClick}
          style={{ cursor: "pointer" }}
        />
      ) : (
        <h4>
          Connected Address:{" "}
          {props.userAddress.slice(0, 8) +
            "......." +
            props.userAddress.slice(35, 42)}
        </h4>
      )}
    </div>
  );
};

export default Connect;
