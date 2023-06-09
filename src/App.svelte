<script>
import Scrolly from "./helpers/Scrolly.svelte";
let currentStep;
const steps = ["initial plot", "intro to quiz", "political quiz", "stats quiz", "end"];
</script>

<main>
<section>
  <div class="sticky">

  <!--put the main chart here-->
    
</div>
<div class="steps">

  <Scrolly bind:value={currentStep}> <!-- 3. This is what updates value -->
    {#each steps as text, i}
        <div class="step" class:active={currentStep === i}> <!-- 4. Dynamically applies the active class -->
          <div class="step-content">
            <p>{text}</p> 
          </div>
        </div>
    {/each}
</Scrolly>
</div>
<div class="current_step">
  Current Scroll Step: {currentStep}
</div>
</section>

</main>

<style>
section{
  position: relative;
}
.sticky{
  position: sticky;
  top: 0;
  z-index: 1;
}
.steps{
  position: relative;
  z-index: 2;
}
.step{
  height: 90vh;
  opacity: 0.3;
  transition: opacity 300ms ease;
  display: flex;
  justify-content: center;
  place-content: center;
}
.step-content{
  background: grey;
  border: 1px solid;
  padding: 0.75rem 1rem;
  border-radius: 3px;
  width: 60vw;
}
.step.active{
  opacity: 1;
}
.current_step{
  position:fixed;
  bottom: 0;
  right:0;
  padding:2;
}
</style>
