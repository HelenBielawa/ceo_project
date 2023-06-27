<script>
    export let data;
    export let xScale;
    export let yScale;
    export let width;
    export let height;
    export let currentStatus;
    export let xVar;
    export let yVar;
    import { fly } from "svelte/transition";
    import {Cursor} from "svelte-bootstrap-icons";

    console.log("in the tooltip, current stat: ", currentStatus)

    console.log("tatus: ", currentStatus)
    let tooltipWidth;
    let tooltipHeight;

    let x = xScale(data[xVar]);
    let y = yScale(data[yVar]);
  
    const xNudge = 20; // shift it a bit to the right
    const yNudge = 20; // shift it a bit down

    $: xPos = data["RIGHT.QUANT_Pred_Mean"] > 50? x - tooltipWidth - xNudge :
              x + xNudge

    $: yPos = data["INDEP.QUANT_Pred_Mean"] > 50? y + yNudge :
              y - tooltipHeight - yNudge

    </script>
  
  <div
    class="tooltip"
    transition:fly={{ y: 10 }}
    style="position: absolute; top: {yPos}px; left: {xPos}px"
    bind:clientWidth={tooltipWidth}
    bind:clientHeight={tooltipHeight}
  >

    {#if currentStatus == "sociodemViz"}
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
      <b>language:</b>{data.LANGUAGE === 1? "Catalan":
                  data.LANGUAGE === 2? "Spanish":
                 "Catalan and Spanish, or other"}<br>
      <b>age:</b> {data.AGE_RANGE}<br>
      <br>
      <Cursor/> {Math.round(data.Perc_Users)}% of all respondents belong to this group. Click to see the individuals</p>
    {:else if currentStatus === "politicalViz" || currentStatus === "top-left"}
    <p>
      <b>age:</b> {Math.round(data.AGE_prop)}% are {data.AGE_cat} years old<br>
      <b>education:</b> {Math.round(data.EDUCATION_prop)}% finished
      {data.EDUCATION_cat === "0" ? "none or primary" : data.EDUCATION_cat === "1" ? "secondary" : "superior"} studies<br>
      <b>language:</b> {Math.round(data.LANGUAGE_prop)}% {data.LANGUAGE_cat === 0? "don't " : ""}prefer to speak Catalan<br>
      {Math.round(data.Perc_Users)}% of all respondents belong to this group.<br>
      <br>
    </p>
    {:else if currentStatus === "groupViz"}
      <p>
        click to get back to the visualization of the social clusters
      </p>
    {/if}
  </div>
  
  <style>
    .tooltip {
      padding: 8px 6px;
      background: white;
      box-shadow: rgba(0, 0, 0, 0.15) 2px 3px 8px;
      border-radius: 3px;
      pointer-events: none;
      max-width: 60%;
      max-height: 30%;
      overflow: none;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
      transition: transform 0.1s ease;
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
      display: block;
      white-space: normal;
    }
  </style>
  