<script>
    import groupData from "../data/testData_groupInfo.json";
    export let data;
    export let xScale;
    export let yScale;
    export let width;
    export let currentStatus;
  
    $: x = xScale(data.rightness);
    $: y = yScale(data.independence);
  
    let tooltipWidth;
  
    const xNudge = 15;
    const yNudge = 30;
  
    $: xPosition =
      x + tooltipWidth > width ? x - tooltipWidth - xNudge : x + xNudge;
    $: yPosition = y + yNudge;

    let groupInfo = groupData.filter(g => g.groupID == data.groupID)[0]
  
    import { fly } from "svelte/transition";
  </script>
  
  <div
    class="tooltip"
    transition:fly={{ y: 10 }}
    style="position: absolute; top: {yPosition}px; left: {xPosition}px"
    bind:clientWidth={tooltipWidth}
  >
    {#if currentStatus == "groupViz"}
      Click on the circle to get back to the main chart.
    {/if}
    {#if currentStatus == "generalViz"}
      <h1>About this group:</h1>
      <h2>area: {groupInfo.area}</h2>
      <h2>age: {groupInfo.age_group}</h2>
      <h2>language: {groupInfo.language}</h2>
      <p>Click on the circle to see the positions of all the {groupInfo.count} individuals in this group.</p>
    {/if}

  </div>
  
  <style>
    .tooltip {
      padding: 8px 6px;
      background: white;
      box-shadow: rgba(0, 0, 0, 0.15) 2px 3px 8px;
      border-radius: 3px;
      pointer-events: none;
      transition: top 300ms ease, left 300ms ease;
    }
  
    h1,
    h2 {
      margin: 0;
      padding: 0;
      font-weight: 300;
    }
  
    h1 {
      font-size: 1rem;
      font-weight: 400;
      margin-bottom: 6px;
      width: 100%;
    }
  
    h2 {
      font-size: 0.8rem;
      text-transform: uppercase;
    }
  
    span {
      background: #dda0dd50;
      font-size: 80%;
      margin-left: 2px;
      padding: 2px 4px;
      display: inline-block;
      vertical-align: bottom;
      border-radius: 3px;
      color: rgba(0, 0, 0, 0.7);
    }
  </style>
  