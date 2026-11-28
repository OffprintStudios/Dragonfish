import { BASE_URL } from "#lib/http";
import type { Blog } from "#lib/models/blogs";
import { PROFILE_ID_KEY, SESSION_TOKEN_KEY } from "#lib/util/constants.ts";
import { error } from "@sveltejs/kit";
import type { PageServerLoad, Actions } from "./$types";

export const load: PageServerLoad = async ({ params, cookies, fetch }) => {
    const blogID = params.id;
    const sessionToken = cookies.get(SESSION_TOKEN_KEY);
    const profileID = cookies.get(PROFILE_ID_KEY);

    const apiResponse = await fetch(`${BASE_URL}/profiles/${profileID}/blogs/${blogID}/draft`, {
        method: 'GET',
        headers: {
            "Authorization": `Bearer ${sessionToken}`,
            "Content-Type": "application/json",
        }
    });

    if (apiResponse.ok) {
        return { blog: (await apiResponse.json()) as Blog }
    }

    throw error(apiResponse.status, apiResponse.statusText);
}

export const actions = {} satisfies Actions;