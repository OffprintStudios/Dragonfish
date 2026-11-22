import { BASE_URL } from "#lib/http";
import type { LayoutServerLoad } from "./$types";
import { SESSION_TOKEN_KEY, PROFILE_ID_KEY } from "#lib/util/constants.ts";
import { error } from "@sveltejs/kit";

export const load: LayoutServerLoad = async ({ fetch, cookies }) => {
    const token = cookies.get(SESSION_TOKEN_KEY);
    const profileID = cookies.get(PROFILE_ID_KEY);

    if (!token || !profileID) {
        throw error(401, "Unauthorized");
    }

    const apiResponse = await fetch(`${BASE_URL}/accounts/profiles/${profileID}/verify`, {
        method: 'GET',
        headers: {
            "Authorization": `Bearer ${token}`,
        }
    });

    if (apiResponse.ok) return;
    throw error(apiResponse.status, apiResponse.statusText);
}