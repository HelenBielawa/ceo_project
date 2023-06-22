<script>
    export let data;
    export let xScale;
    export let yScale;
    export let width;
    export let currentStatus;
    import { fly } from "svelte/transition";
  import App from "../App.svelte";
  import AxisX from "./AxisX.svelte";
  import AxisY from "./AxisY.svelte";
  import {Cursor} from "svelte-bootstrap-icons";
 
    console.log("entering tooltip, this is its data: ", data)
    $: x = xScale(data.RIGHT_Pred_Mean);
    $: y = yScale(data.INDEP_Pred_Mean * 10);
  
    let tooltipWidth;
  
    const xNudge = 15;
    const yNudge = 30;
  
    $: xPosition =
      x + tooltipWidth > width ? x - tooltipWidth - xNudge : x + xNudge;
    $: yPosition = y + yNudge;

    </script>
  
  <div
    class="tooltip"
    transition:fly={{ y: 10 }}
    style="position: absolute; top: {yPosition}px; left: {xPosition}px"
    bind:clientWidth={tooltipWidth}
  >
    {#if currentStatus == "groupViz"}
      Click on the circle to get back to the main chart.
    {:else if currentStatus == "sociodemViz"}
      <p>
      <b>province:</b> {data.PROVINCE === 0 ? "Barcelona":
                  data.PROVINCE === 1 ? "Girona" :
                  data.PROVINCE === 2 ? "Lleida":
                  "Tarragona"}<br>
      <b>municipality size:</b> {data.MUNICIPALITY === 0? "< 10.000":
                      data.MUNICIPALITY === 1 ? "10 - 50.000":
                      data.MUNICIPALITY === 2 ? "50 - 150.000":
                      data.MUNICIPALITY === 3 ? "150 - 1.000.000":
                      ">1.000.000"}<br>
      <b>language:</b> {data.LANGUAGE === 1? "Catalan":
                  data.LANGUAGE === 2? "Spanish":
                 "Catalan and Spanish, or other"}<br>
      <b>age:</b> {data.AGE_RANGE}<br>
      <br>
      <Cursor/> See all {data.Num_Users} members</p>
    {:else if currentStatus == "politicalViz"}
    <p>
      {data.NUM} people belong to this group.
      <b>age:</b> {Math.round(data.AGE_prop * 100)}% are {data.AGE} years old.<br>
      <b>education:</b> {Math.round(data.EDUCATION_prop * 100)}% are {data.EDUCATION_cat} educated<br>
      <b>language:</b>{Math.round(data.EDUCATION_prop * 100)}% speak {data.LANGUAGE_cat} language<br>
      <br>
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
      max-width: 60%;
      max-height: 30%;
      overflow: auto;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
      transition: transform 0.3s ease;
      background-image: linear-gradient(to bottom right, #ffffff, #eaeaea);
      border-radius: 8px;
    }
   
    h1 {
      font-size: 1rem;
      font-weight: 400;
      margin-bottom: 6px;
      width: 100%;
    }
  
    p{
      text-align: left;
    }
  </style>
  