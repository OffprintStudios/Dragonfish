<script lang="ts">
    import { CreateNav } from "#lib/ui/nav";
    import { IconDeviceFloppy } from "@tabler/icons-svelte";
    import { CrEditor } from "#lib/ui/forms";
</script>

<form>
    <CreateNav
        showNav={false}
        returnURL="/create/blogs"
    >
        {#snippet header()}
            <h3 class="flex items-center text-xl font-bold tracking-tighter text-cr-header! relative top-0.5">Add a New Blog</h3>
        {/snippet}
        {#snippet tools()}
            <button class="cr-button" type="submit">
                <span class="button-icon"><IconDeviceFloppy size="1.125rem" /></span>
                <span class="button-text">Save</span>
            </button>
        {/snippet}
    </CreateNav>
    <div class="flex flex-col w-full max-w-7xl h-[calc(100dvh-56px)] pt-12 pb-8 mx-auto">
        <textarea
            id="title"
            name="title"
            placeholder="A Day in the Life"
            maxlength="48"
            class="resize-none field-sizing-content box-border w-full text-center content-center h-24 text-5xl font-header text-cr-header placeholder:text-cr-select placeholder:relative placeholder:top-0.5 border-0 bg-transparent focus:ring-0 focus:border-0"
        ></textarea>
        <div class="border-b w-7/12 mx-auto pt-2 mb-8 border-cr-header"></div>
        <CrEditor
            name="body"
            placeholder="On a cool summer's day, in the lonesome quiet beneath the willow..."
        />
    </div>
</form>
