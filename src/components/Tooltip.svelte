<script>
    import { fly } from "svelte/transition";
    import {Cursor} from "svelte-bootstrap-icons";

    export let data;
    export let xScale;
    export let yScale;
    export let width;
    export let height;
    export let currentStatus;
    export let xVar;
    export let yVar;
    export let isEnglish;

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

  {#if isEnglish}

    {#if currentStatus == "sociodemViz"}
      <p>
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
      {data.EDUCATION_cat === "1" ? "secondary" : "superior"} studies<br>
      <b>language:</b> {Math.round(data.LANGUAGE_prop)}% prefer to speak {data.LANGUAGE_cat === "1"? "Catalan" : "Spanish"}<br>
      {Math.round(data.Perc_Users)}% of all respondents belong to this group.<br>
      <br>
    </p>
    {:else if currentStatus === "groupViz"}
      <p>
        click to get back to the visualization of the social clusters
      </p>
    {/if}


    {:else}


    {#if currentStatus == "sociodemViz"}
      <p>
      <b>mida del municipi:</b> {data.MUNICIPALITY === 0? "< 10.000":
                      data.MUNICIPALITY === 1 ? "10 - 50.000":
                      data.MUNICIPALITY === 2 ? "50 - 150.000":
                      data.MUNICIPALITY === 3 ? "150 - 1.000.000":
                      ">1.000.000"}<br>
      <b>idioma:</b>{data.LANGUAGE === 1? "Catalan":
                  data.LANGUAGE === 2? "Spanish":
                 "Catalan and Spanish, or other"}<br>
      <b>edat:</b> {data.AGE_RANGE}<br>
      <br>
      <Cursor/> {Math.round(data.Perc_Users)}% of all respondents belong to this group. Click to see the individuals</p>
    {:else if currentStatus === "politicalViz" || currentStatus === "top-left"}
    <p>
      <b>edat:</b> un {Math.round(data.AGE_prop)}% tenen {data.AGE_cat} anys<br>
      <b>formació:</b> un {Math.round(data.EDUCATION_prop)}% té estudis
      {data.EDUCATION_cat === "1" ? "secundaris" : "superiors"}<br>
      <b>idioma:</b> un {Math.round(data.LANGUAGE_prop)}% prefereix parlar {data.LANGUAGE_cat === "1"? "catalá" : "castellà"}<br>
      un {Math.round(data.Perc_Users)}% dels enquestats pertanyen a aquest grup<br>
      <br>
    </p>
    {:else if currentStatus === "groupViz"}
      <p>
        feu clic per tornar a la visualització dels clústers socials
      </p>
    {/if}

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
  