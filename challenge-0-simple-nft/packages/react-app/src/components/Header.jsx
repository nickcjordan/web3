import { PageHeader } from "antd";
import React from "react";

// displays a page header

export default function Header() {
  return (
    <a href="https://github.com/nickcjordan/wontopia" target="_blank" rel="noopener noreferrer">
      <PageHeader
        title="WONTOPIA"
        subTitle="nick & dan"
        style={{ cursor: "pointer" }}
      />
    </a>
  );
}
