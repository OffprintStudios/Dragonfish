import { PROFILE_ID_KEY, SESSION_TOKEN_KEY } from "#lib/util/constants";
import type { PageServerLoad } from "./$types";
import { BASE_URL } from "#lib/http";
import { error } from "@sveltejs/kit";
import type { Paginate } from "#lib/models/util/tools";
import type { Blog } from "#lib/models/blogs";

export const load: PageServerLoad = async ({ fetch, cookies }) => {
    const token = cookies.get(SESSION_TOKEN_KEY);
    const profileID = cookies.get(PROFILE_ID_KEY);

    if (!token || !profileID) {
        throw error(401, "Unauthorized");
    }

    const apiResponse = await fetch(`${BASE_URL}/profiles/${profileID}/blogs/all`, {
        method: 'GET',
        headers: {
            "Authorization": `Bearer ${token}`,
        }
    });

    if (apiResponse.ok) {
        return { blogs: (await apiResponse.json()) as Paginate<Blog> }
    }

    throw error(apiResponse.status, apiResponse.statusText);
}