from omero.gateway import BlitzGateway


class CpOmeroClient(object):
    '''

    OMERO client.

    '''

    def __init__(self, credentails):
        return

    def login():
        retun

    def logout():
        return

    def close():
        retun

    def connection_details():
        return


class OmeroImageReader(object):
    '''

    OmeroImageReader class uses a single
    OMERO client instance to exchange data
    with the OMERO server.

    RawPixelsStore per image instance is used
    and cached the image realted data.

    '''

    def __init__(self, path=None, url=None, perform_init=True):
        return self

    def __enter__(self):
	return self

    def __exit__(self, type_class, value, traceback):
        self.close()

    def close(self):
        return

    def init_reader(self):
        return

    def read(
        self, c = None, z = 0, t = 0,
        series = None, index  None, rescale = True,
        wants_max_intensity = False, channel_names = None
    ):
        return


from bioformats.formatsreader import __image_reader_key_cache
from bioformats.formatsreader import __image_reader_cache


def get_omero_image_reader(key, path = None, url = None):
    '''

    '''
    if key in __image_reader_key_cache:
        old_path, old_url = __image_reader_key_cache[key]
        old_count, rdr = __image_reader_cache[old_path, old_url)
        if old_path == path and old_url == url:
            return rdr
        release_image_reader(key)
    else:
        rdr = OmeroImageReader(path=path, url=url)
        old_count = 0
    __image_reader_cache[path, url] = (old_count + 1, rdr)
    __image_reader_key_cache[key] = (path, url)
    return rdr
